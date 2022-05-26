module Api::V1
  class ApidocsController < ApiController
    skip_before_action :authenticate
    include Swagger::Blocks

    swagger_root do
      key :swagger, '2.0'
      info do
        key :version, '1.0.0'
        key :title, 'Playbook API Documentation'
        key :description, 'API documentation for Playbook Sports'
      end
      tag do
        key :name, 'user'
        key :description, 'Users operations'
        externalDocs do
          key :description, 'Find more info here'
          key :url, 'https://swagger.io'
        end
      end
      tag do
        key :name, 'passwordReset'
        key :description, 'Password Reset'
        externalDocs do
          key :description, 'Find more info here'
          key :url, 'https://swagger.io'
        end
      end
      tag do
        key :name, 'register'
        key :description, 'User Sign Up'
        externalDocs do
          key :description, 'Find more info here'
          key :url, 'https://swagger.io'
        end
      end
      tag do
        key :name, 'session'
        key :description, 'User Sign In'
        externalDocs do
          key :description, 'Find more info here'
          key :url, 'https://swagger.io'
        end
      end
      tag do
        key :name, 'friend'
        key :description, 'Friends operations'
        externalDocs do
          key :description, 'Find more info here'
          key :url, 'https://swagger.io'
        end
      end
      security_definition :api_key do
        key :type, :apiKey
        key :name, :Authorization
        key :in, :header
      end
      key :host, ENV['DOMAIN']
      key :basePath, '/'
      key :consumes, ['application/json', 'application/x-www-form-urlencoded']
      key :produces, ['application/json']
    end

    # A list of all classes that have swagger_* declarations.
    SWAGGERED_CLASSES = [
      FriendshipsController,
      UsersController,
      Friendship,
      User,
      Users::SessionsController,
      Users::RegistrationsController,
      # ErrorModel,
      self,
    ].freeze

    def index
      render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
    end
  end 
end