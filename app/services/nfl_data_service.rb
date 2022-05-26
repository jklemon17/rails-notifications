require 'uri'
require 'net/http'
require 'openssl'

class NflDataService
  def initialize(endpoint)
    @api_key = ENV['SPORTRADAR_API_KEY']
    @url = URI("https://api.sportradar.us/nfl/official/#{Rails.env.development? ? "trial" : "production"}/v6/en/#{endpoint}.json?api_key=#{@api_key}")

    @http = Net::HTTP.new(@url.host, @url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def get_data
    request = Net::HTTP::Get.new(@url)
    response = @http.request(request)
    JSON.parse(response.read_body)
  end
end
