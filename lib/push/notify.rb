module Push
  class Notify
    include HTTParty
    HEADERS = { "Authorization" => "Basic #{ENV['ONESIGNAL_API_KEY']}", "Content-Type" => "application/json" }
    # Create new file to storage log of pushes.
    @push_logger = ::Logger.new(Rails.root.join('log', 'push.log'))
    # Set Onesignal URI
    @uri = URI.parse('https://onesignal.com/api/v1/notifications')

    def self.send_push(body)
      HTTParty.post @uri, headers: HEADERS, body: body, logger: @push_logger, log_level: :debug, log_format: :curl
    end

    def self.jsonify_body(type:, title:, contents:, user_id: nil)
      { app_id: ENV['ONESIGNAL_APP_ID'],
        included_segments: (['All'] unless user_id),
        data: { type: type },
        title: { en: title },
        include_external_user_ids: ([user_id] if user_id),
        contents: { en: contents } 
      }.compact.to_json
    end 
    
    # Use send for both mass & single user notifications. 
    # Simply do not send user_id for a mass notification. 
    def self.send(type:, title:, contents:, user_id: nil) 
      body = jsonify_body(type: type, title: title, contents: contents, user_id: user_id) 
      send_push(body)
    end
  end
end
