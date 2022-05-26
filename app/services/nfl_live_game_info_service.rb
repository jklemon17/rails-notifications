require 'httpclient'

class NflLiveGameInfoService
  attr_reader :url, :logger

  def initialize
    @api_key = ENV['SPORTRADAR_API_KEY']
    @url = URI("http://api.sportradar.us/nfl/official/#{Rails.env.development? ? "trial" : "production"}/stream/en/events/subscribe?api_key=#{@api_key}")
    @logger = Logger.new(Rails.root.join('log', 'live_game_info.log'))
    @client = HTTPClient.new(agent_name: 'SportsData/1.0')
    @start_time = Time.current
  end

  def start
    @client.get(@url, follow_redirect: true) do |chunk|
      begin
        proper_json = chunk.chomp.prepend("[").gsub(/[\r]/, ',') << ']'
        game_info_hash = JSON.parse(proper_json)

        @logger.debug game_info_hash

        game_info_hash.each do |info|
          payload = info["payload"]
          next unless payload && payload["game"]

          game = payload["game"]
          @game = Game.find_or_create_by(sportradar_id: game["id"])
          @game.update(game_status: game["status"], quarter: game["quarter"], clock: game["clock"], home_team_score: game["summary"]["home"]["points"], away_team_score: game["summary"]["away"]["points"])
        end

      rescue JSON::ParserError
        puts "Parsing failed - malformed data"
        @logger.debug "Parsing failed - malformed data"
      rescue => error
        @logger.debug error.message
      end

      # Stop the stream after 12 hours
      break if Time.current > (@start_time + 12.hours)
    end
  end

end
