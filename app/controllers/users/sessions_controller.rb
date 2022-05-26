# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Swagger::Blocks
  # before_action :configure_sign_in_params, only: [:create]
  protect_from_forgery with: :null_session

  swagger_path '/users/sign_in' do
    operation :post do
      key :summary, 'Sign In'
      key :description, 'Sign in with email and password'
      key :operationId, 'signIn'
      key :consumes, ['application/x-www-form-urlencoded']
      key :produces, ['application/json']
      key :tags, [
        'session'
      ]

      parameter type: :string, name: "user[email]", description: "User's email address", required: true, in: :formData
      parameter type: :string, name: "user[password]", description: "User's password", required: true, in: :formData
      
      response 200 do
        key :description, 'User response'
        schema do
          key :type, :array
          items do
            key :'$ref', :User
          end
        end
      end
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    resource = warden.authenticate(:scope => resource_name)
    return render_unauthorized unless resource
   
    success_response(UserSerializer.new(resource, {params: {current_user: resource}}).serializable_hash)
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end