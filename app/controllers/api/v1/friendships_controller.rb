module Api::V1
  class FriendshipsController < ApiController
    include Swagger::Blocks
    before_action :set_friendship, only: [:update]

    swagger_path '/api/v1/friendships' do
      operation :get do
        key :summary, 'Friends Index'
        key :description, 'This endpoint is used for three purposes: 1) Get all friends of the current user; 2) Search friends of current user; 3) Get pending friend requests'
        key :operationId, 'friendsIndex'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'friend'
        ]

        parameter type: :string, name: :search, description: "Search for a friend (by first/last name or username)", required: false, in: :query
        parameter type: :boolean, name: :requests, description: "Get pending requests instead of current friends", required: false, in: :query
        parameter type: :string, name: :user_id, description: "User ID to get User's friend's list", required: false, in: :query

        response 200 do
          key :description, 'Success'
          schema do
            key :type, :array
            items do
              key :'$ref', :User
            end
          end
        end
      end
    end

    swagger_path '/api/v1/friendships/' do
      operation :post do
        key :summary, 'Create friendship (friend request)'
        key :description, 'Create a friend request'
        key :operationId, 'friendshipsCreate'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'friend'
        ]

        parameter type: :string, name: "friendship[friend_id]", description: "ID of the user you wish to 'friend'", required: true, in: :formData

        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :Friendship
          end
        end
      end
    end

    swagger_path '/api/v1/friendships/{id}' do
      operation :patch do
        key :summary, 'Update (accept/decline/block friendship)'
        key :description, 'Update a friendship'
        key :operationId, 'friendshipsUpdate'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'friend'
        ]

        parameter type: :string, name: :id, description: "ID of friendship to update", required: true, in: :path
        parameter type: :string, name: "friendship[status]", description: "Status to set", required: true, in: :formData

        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :Friendship
          end
        end
      end
    end

    # GET /v1/friendships
    def index
      #TODO SPLIT INTO SEPERATE ACTIONS
      if params[:requests] # Get pending friend requests instead of current friends
        @friend_requests = Friendship.where(friend: current_user, status: :requested)
        return success_response(FriendshipSerializer.new(@friend_requests).serializable_hash)
      elsif params[:search] # Search for friends (by name or username)
        name, surname = params[:search].split
        @friends = surname ? current_user.friends.search_by_two_names(name, surname) : current_user.friends.search_by_one_name(name)
      elsif params[:user_id] # Get someone elses friends
        @friends = User.find(params[:user_id]).friends
      else # Get your own friends
        @friends = current_user.friends
      end
      success_response(UserSerializer.new(@friends).serializable_hash)
    end

    # POST /v1/friendships
    def create
      @friendship = Friendship.new(user: current_user, friend_id: params[:friendship][:friend_id])
      success_response(FriendshipSerializer.new(@friendship).serializable_hash) if @friendship.save!
      Push::Notify.send(title: "", 
                        contents: "#{current_user.first_name} #{current_user.last_name} (#{current_user.username}) added you as a friend.", 
                        type: "new_friend_request", 
                        user_id: @friendship.friend.id)
    end

    # PATCH/PUT v1/friendships/1
    def update
      case friendship_params[:status].to_sym
      when :accepted
        current_user.accept_friend(@friendship.user)
      when :declined
        @friendship.update!(friendship_params)
      when :blocked
        current_user.block_friend(other_user)
      end

      @friendship.reload
      success_response(FriendshipSerializer.new(@friendship).serializable_hash)
    end

    private
    # Use callbacks to share common setup or constraints between actions.

    def set_friendship
      @friendship = Friendship.find(params[:id])
    end

    def friendship_params
      params.require(:friendship).permit(
        :status,
        :friend_id,
      )
    end

    def other_user
      @friendship.user == current_user ? @friendship.friend : @friendship.user
    end

  end
end
