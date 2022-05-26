require 'httpclient'

class NflLiveStatsService
  attr_reader :url, :logger

  def initialize
    @api_key = ENV['SPORTRADAR_API_KEY']
    @url = URI("http://api.sportradar.us/nfl/official/#{Rails.env.development? ? "trial" : "production"}/stream/en/statistics/subscribe?api_key=#{@api_key}")
    @logger = Logger.new(Rails.root.join('log', 'live_stats.log'))
    @client = HTTPClient.new(agent_name: 'SportsData/1.0')
    @start_time = Time.current
  end

  def start
    @client.get(@url, follow_redirect: true) do |chunk|
      begin
        proper_json = chunk.chomp.prepend("[").gsub(/[\r]/, ',') << ']'
        stats_hash = JSON.parse(proper_json)

        @logger.debug stats_hash # Keeping this here, but moving it to the debugger, as I think it may be handy from time to time.

        stats_hash.each do |stats|
          payload = stats["payload"]
          metadata = stats["metadata"]
          next unless payload && payload["player"] && metadata && metadata["match"]

          player = payload["player"]["id"]
          game = metadata["match"][9..44]
          next unless game && player

          @logger.debug @game.inspect

          if payload["receiving"]
            receptions = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                          game_sportradar_id: game,
                                          stat_name: "receptions")
            receptions.update!(value: payload["receiving"]["receptions"])

            rec_yards = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                        game_sportradar_id: game,
                                        stat_name: "rec_yd")
            rec_yards.update!(value: payload["receiving"]["yards"])

            rec_touchdowns = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                              game_sportradar_id: game,
                                              stat_name: "rec_td")
            rec_touchdowns.update!(value: payload["receiving"]["touchdowns"])
          end

          if payload["rushing"]
            rushing_yards = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                            game_sportradar_id: game,
                                            stat_name: "rushing_yd")
            rushing_yards.update!(value: payload["rushing"]["yards"])
          
            rushing_touchdowns = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                                  game_sportradar_id: game,
                                                  stat_name: "rushing_td")
            rushing_touchdowns.update!(value: payload["rushing"]["touchdowns"])
          end

          if payload["passing"]
            passing_yards = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                            game_sportradar_id: game,
                                            stat_name: "passing_yd")
            passing_yards.update!(value: payload["passing"]["yards"])

            passing_touchdowns = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                                 game_sportradar_id: game,
                                                 stat_name: "passing_td")
            passing_touchdowns.update!(value: payload["passing"]["touchdowns"])

            interceptions = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                            game_sportradar_id: game,
                                            stat_name: "interceptions")
            interceptions.update!(value: payload["passing"]["interceptions"])
          end

          if payload["fumbles"]
            fumbles_lost = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                            game_sportradar_id: game,
                                            stat_name: "fumbles_lost")
            fumbles_lost.update!(value: payload["fumbles"]["lost_fumbles"])
          
            fumble_recovered_td = PlayerGameStat.find_or_create_by(player_sportradar_id: player,
                                                  game_sportradar_id: game,
                                                  stat_name: "fumble_recovered_td")
            fumble_tds = payload["fumbles"]["own_rec_td"] + payload["fumbles"]["opp_rec_td"] + payload["fumbles"]["ez_rec_td"]
            fumble_recovered_td.update!(value: fumble_tds )
          end

          # Two point conversions need to be added - don't have any examples of where that data is in the payload
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
