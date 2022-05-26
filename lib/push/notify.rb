module Push
  class Notify
    include HTTParty
    HEADERS = { "Authorization" => "Basic #{ENV['ONESIGNAL_API_KEY']}", "Content-Type" => "application/json" }
    # Create new file to storage log of pushes.
    @push_logger = ::Logger.new(Rails.root.join('log', 'push.log'))
    # Set Onesignal URI
    @uri = URI.parse('https://onesignal.com/api/v1/notifications')

    def self.send_single_push(type:, title:, contents:, user_id:)
      body = { app_id: ENV['ONESIGNAL_APP_ID'],
                data: { type: type },
                title: { en: title },
                include_player_ids: (user_id),
                contents: { en: contents } 
             }.compact.to_json

      HTTParty.post @uri, headers: HEADERS, body: body, logger: @push_logger, log_level: :debug, log_format: :curl
    end

    def self.send_mass_push(type:, title:, contents:)
      body = { app_id: ENV['ONESIGNAL_APP_ID'],
                included_segments: (['All']),
                data: { type: type },
                title: { en: title },
                contents: { en: contents } 
             }.compact.to_json

      HTTParty.post @uri, headers: HEADERS, body: body, logger: @push_logger, log_level: :debug, log_format: :curl
    end
    
    # Use send for both mass & single user notifications. 
    # Simply do not send user_id for a mass notification. 
    def self.send(type:, title:, contents:, user_id: nil)
      user_id ? 
                send_single_push(type:, title:, contents:, user_id:)
                send_mass_push(type:, title:, contents:)
    end
  end
end