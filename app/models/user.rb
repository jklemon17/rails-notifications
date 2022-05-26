class User < ApplicationRecord
  include Swagger::Blocks
  include Devise::JWT::RevocationStrategies::JTIMatcher

  swagger_schema :User do
    key :required, [:first_name, :last_name, :username, :email, :order_privacy, :date_of_birth]
    property :first_name do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :username do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
    property :order_privacy do
      key :type, :string
    end
    property :date_of_birth do
      key :type, :string
    end
  end

  has_many :friendships, dependent: :destroy

  scope :search_by_one_name, -> (search) {(where("first_name ILIKE ? OR last_name ILIKE ? OR username ILIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")).limit(10)}
  scope :search_by_two_names, -> (first,last) {(where("first_name ILIKE ? AND last_name ILIKE ?", "%#{first}%", "%#{last}%")).limit(10)}

  enum order_privacy: {
    everyone: 0,
    friends: 1,
    self: 2
  }

  enum tsevo_status: {
    pending: 0,
    approved: 1,
    blocked: 2,
    flagged: 3,
  }

  after_create :assign_color # CLIENT DOESNT WANT TO VALIDATE IDENTITY UNTIL FIRST DEPOSIT BUILT INTO DEPOSIT FLOW, :validate_identity
  before_destroy :destroy_friendships

  def friends
    User.where(id: Friendship.where(user: self, status: :accepted).pluck(:friend_id))
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
  :recoverable, :rememberable, :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: self
  self.skip_session_storage = [:http_auth, :params_auth]

  def generate_reset_code
    update(reset_code: Array.new(4){ rand(10) }.join)
  end

  def send_password_reset_email
    self.generate_reset_code
    UserMailer.reset_password(self)
  end

  def assign_color
    colors = ["#FBBB00", "#F3594E", "#32FFB8", "#4669E4", "#93A2FF", "#71BEFF"]
    self.update(color: colors.sample)
    if User.count < 100
      Transaction.create(user: self, deposit: true, status: :complete, amount:0, bonus_amount:10000)
      self.update(color: colors.sample, bonus_balance: 10000)
    else
      self.update(color: colors.sample)
    end
  end

  def accept_friend(friend)
    accept_friend_request(friend)
    create_reciprocal_request(friend)
  end

  def block_friend(friend)
    block_one_way(friend, self)
    block_one_way(self, friend)
  end

  private

  def accept_friend_request(friend)
    request = Friendship.find_by(user: friend, friend: self)
    request.update!(status: :accepted)
    Push::Notify.send(title: "", 
                      contents: "#{first_name} #{last_name} (#{username}) accepted your friend request.", 
                      type: "accept_friend_request", 
                      user_id: friend.id)
  end

  def create_reciprocal_request(friend)
    if @friendship = Friendship.find_by(user: self, friend: friend)
      @friendship.update!(status: :accepted)
    else
      Friendship.create!(user: self, friend: friend, status: :accepted)
    end
  end

  def block_one_way(user, friend)
    friendship = Friendship.find_or_create_by(user: user, friend: friend)
    friendship.update!(status: :blocked)
  end

  def destroy_friendships
    Friendship.where(user: self).or(Friendship.where(friend: self)).destroy_all
  end
end
