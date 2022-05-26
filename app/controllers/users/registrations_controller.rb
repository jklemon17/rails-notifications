# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include Swagger::Blocks

  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  protect_from_forgery with: :null_session
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_response

  swagger_path '/users' do
    operation :post do
      key :summary, 'Sign Up'
      key :description, 'Sign up with email and password'
      key :operationId, 'signUp'
      key :consumes, ['application/x-www-form-urlencoded']
      key :produces, ['application/json']
      key :tags, [
        'register'
      ]

      parameter type: :string, name: "user[email]", description: "Email address", required: true, in: :formData
      parameter type: :string, name: "user[password]", description: "Enter password", required: true, in: :formData
      parameter type: :string, name: "user[password_confirmation]", description: "Confirm password", required: true, in: :formData
      parameter type: :string, name: "user[first_name]", description: "First Name", required: true, in: :formData
      parameter type: :string, name: "user[last_name]", description: "Last Name", required: true, in: :formData
      parameter type: :string, name: "user[username]", description: "Username", required: true, in: :formData
      parameter type: :string, name: "user[date_of_birth]", description: "Birthday (mm/dd/yyyy)", required: true, in: :formData
      
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

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |resource|
      if resource.persisted?
        sign_up(resource_name, resource)
        UserMailer.welcome_email(resource)
        return success_response(UserSerializer.new(resource).serializable_hash)  
      else
        clean_up_passwords resource
        set_minimum_password_length
        raise ActiveRecord::RecordInvalid.new(resource)
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :date_of_birth])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
