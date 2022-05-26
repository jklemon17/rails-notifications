module Api::V1
  class UsersController < ApiController
    include Swagger::Blocks
    skip_before_action :authenticate, only: [:password_reset_create, :password_reset_update, :user_available]
    before_action :set_user, only: [:show, :update, :destroy]
    
    swagger_path '/api/v1/users' do
      operation :get do
        key :summary, 'View users'
        key :description, 'Get all users'
        key :operationId, 'usersIndex'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'user'
        ]
  
        parameter type: :string, name: :search, description: "Search for a user (by first/last name or username)", required: false, in: :query
        
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

    swagger_path '/api/v1/users/{id}' do
      operation :get do
        key :summary, 'View user'
        key :description, 'Get one user'
        key :operationId, 'usersShow'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'user'
        ]
  
        parameter type: :string, name: :id, description: "ID of user to fetch", required: true, in: :path
        
        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :User
          end
        end
      end
    end

    swagger_path '/api/v1/users/{id}' do
      operation :patch do
        key :summary, 'Update user'
        key :description, 'Update a user'
        key :operationId, 'usersUpdate'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'user'
        ]
  
        parameter type: :string, name: :id, description: "ID of user to update", required: true, in: :path
        parameter type: :string, name: "user[first_name]", description: "User's first name", required: false, in: :formData
        parameter type: :string, name: "user[last_name]", description: "User's last name", required: false, in: :formData
        parameter type: :string, name: "user[username]", description: "Username", required: false, in: :formData
        parameter type: :string, name: "user[email]", description: "Email", required: false, in: :formData
        parameter type: :integer, name: "user[order_privacy]", description: "Order Privacy (0 = everyone; 1 = friends; 2 = self)", required: false, in: :formData
        
        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :User
          end
        end
      end
    end

    swagger_path '/api/v1/users/{id}' do
      operation :delete do
        key :summary, 'Delete user'
        key :description, 'Delete a user'
        key :operationId, 'usersDelete'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'user'
        ]

        parameter type: :string, name: :id, description: "ID of user to delete", required: true, in: :path

        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :User
          end
        end
      end
    end

    swagger_path '/api/v1/users/top' do
      operation :get do
        key :summary, 'Top users'
        key :description, 'Get top users by activity score'
        key :operationId, 'usersTop'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'user'
        ]

        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :User
          end
        end
      end
    end

    swagger_path '/api/v1/users/available' do
      operation :get do
        key :summary, 'Check username availability'
        key :description, 'Check if any users have taken a given username'
        key :operationId, 'usernameCheck'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'user'
        ]

        parameter type: :string, name: :username, description: "Desired Username", required: false, in: :query
        parameter type: :string, name: :email, description: "Desired Email Address", required: false, in: :query

        response 200 do
          key :description, 'Success'
        end

        response 422 do
          key :description, 'Username taken'
        end
      end
    end

    # Password Resets

    swagger_path '/api/v1/users/password_resets' do
      operation :post do
        key :summary, 'Password Reset Request'
        key :description, 'Request a password reset for the user'
        key :operationId, 'passwordResetCreate'
        key :consumes, ['application/json']
        key :produces, ['application/json']
        key :tags, [
          'passwordReset'
        ]
  
        parameter type: :string, name: :email, description: "User's email", required: true, in: :formData
        
        response 200 do
          key :description, 'Success'
        end
      end
    end

    swagger_path '/api/v1/users/password_resets' do
      operation :patch do
        key :summary, 'Continue Password Reset'
        key :description, 'Verify code or submit new password'
        key :operationId, 'passwordResetUpdate'
        key :consumes, ['application/x-www-form-urlencoded']
        key :produces, ['application/json']
        key :tags, [
          'passwordReset'
        ]
  
        parameter type: :string, name: :email, description: "User's email", required: true, in: :formData
        parameter type: :string, name: :reset_code, description: "Reset code sent to user", required: true, in: :formData
        parameter type: :string, name: :new_password, description: "User's new password", required: false, in: :formData
        
        response 200 do
          key :description, 'Success'
          schema do
              key :'$ref', :User
          end
        end
      end
    end

    # GET /users
    def index
      if params[:search] # Search for users (by name or username)
        name, surname = params[:search].split
        @users = surname ? User.search_by_two_names(name, surname) : User.search_by_one_name(name)
      else # Get all users (excluding current user)
        @users = User.where.not(id: current_user.id)
      end
      success_response(UserSerializer.new(@users,{params: {current_user: current_user}}).serializable_hash)
    end

    # GET /users/top
    def top_people
      friendships = current_user.friendships.where(status: :accepted).order(activity_score: :desc).limit(4)
      friends = friendships.map{|friendship| friendship.friend}
      if friends.length == 4
        success_response(UserSerializer.new(friends,{params: {current_user: current_user}}).serializable_hash)
      else
        @users = User.where.not(id:current_user.id).order(activity_score: :desc).limit(4)
        success_response(UserSerializer.new(@users,{params: {current_user: current_user}}).serializable_hash)
      end
    end

    # GET /users/1
    def show
      success_response(UserSerializer.new(@user,{params: {current_user: current_user}}).serializable_hash)
    end

    # PATCH/PUT /users/1
    def update
      @user.update_attributes!(user_params)
      success_response(UserSerializer.new(@user).serializable_hash)
    end

    # DELETE /users/1
    def destroy
      @user.destroy
      return json_response(error: "User could not be deleted", status: 500) unless @user.destroyed?
      json_response(status: 204)
    end

    # GET /v1/users/available
    def user_available
      if params[:email]
        @user = User.find_by(email: params[:email])
        @user ? json_response(error: "This email is already in use", status: 422) : success_response("Email Available")
      elsif params[:username]
        @user = User.find_by(username: params[:username])
        @user ? json_response(error: "This username is already taken", status: 422) : success_response("Username Available")
      else
        json_response(error: "No email or username provided", status: 422)
      end
    end

    # POST /v1/users/password_resets
    def password_reset_create
      @user = User.find_by(email: params[:email].downcase)
      return user_not_authorized("No account was found with this email.") unless @user
      @user.send_password_reset_email
      success_response("4-digit reset code sent to #{@user.email}")
    end

    # PATCH/PUT /v1/users/password_resets 
    def password_reset_update
      @user = User.find_by(email: params[:email].downcase)
      return json_response(status: 422, error: "No account was found with this email.") unless @user
      return json_response(status: 422, error: "Verification code entered is incorrect") unless params[:reset_code] == @user.reset_code
      return success_response("Code verified!") unless params[:new_password]
      @user.update!(password: params[:new_password], reset_code: nil)
      success_response(UserSerializer.new(@user).as_json)
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :username, :order_privacy, :date_of_birth)
    end

  end
end
