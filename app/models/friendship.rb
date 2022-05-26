class Friendship < ApplicationRecord
  include Swagger::Blocks

  swagger_schema :Friendship do
    key :required, [:user_id, :friend_id, :status]
    property :user_id do
      key :type, :string
    end
    property :friend_id do
      key :type, :string
    end
    property :status do
      key :type, :integer
    end
  end

  belongs_to :user
  belongs_to :friend, foreign_key: :friend_id, class_name: 'User'

  enum status: {
    requested: 0,
    accepted: 1,
    declined: 2,
    blocked: 3
  }

  validates_uniqueness_of :friend_id, scope: :user_id
end
