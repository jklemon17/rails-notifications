module Api::V1
  class ApiController < ActionController::API
    include ApplicationHelper
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate, except: [:index_public]
    # Throttling should be re-enabled once we can get it to properly connect to Redis
    # before_action :throttle_token

    rescue_from StandardError do |exception|
      # Sentry.capture_exception(exception)
      json_response(error: exception.message, status: 500)
    end
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_response
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

    def current_user
      @_current_user ||= authenticate_token
    end

    protected

    def authenticate
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        @token = token
        begin
          @current_user = User.find_by(jti: JWT.decode(token, Rails.application.credentials.jwt_secret_key,"H256")[0]["jti"])
        rescue
          break
          render_unauthorized
        end
      end
    end

    def throttle_ip
      return unless Rails.env.production?
      client_ip = request.env["REMOTE_ADDR"]
      key = "count:#{client_ip}"
      count = REDIS.get(key)

      unless count
        REDIS.set(key, 0)
        REDIS.expire(key, THROTTLE_TIME_WINDOW)
        return true
      end

      if count.to_i >= THROTTLE_MAX_REQUESTS
        render :json => {:message => "You have fired too many requests. Please wait for some time."}, :status => 429
        return
      end
      REDIS.incr(key)
      true
    end

    def throttle_token
      return unless Rails.env.production?
      if @token.present?
        key = "count:#{@token}"
        count = REDIS.get(key)

        unless count
          REDIS.set(key, 0)
          REDIS.expire(key, THROTTLE_TIME_WINDOW)
          return true
        end

        if count.to_i >= THROTTLE_MAX_REQUESTS
          render :json => {:message => "You have fired too many requests. Please wait for some time."}, :status => 429
          return
        end
        REDIS.incr(key)
        true
      else
        false
      end
    end

  end
end
