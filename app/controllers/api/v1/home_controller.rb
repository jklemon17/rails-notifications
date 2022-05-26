module Api::V1
  class HomeController < ApiController
    def index_public
      render json: { message: "This is the Playbook API. To use the API, go to the API documentation at #{ENV['SWAGGER_BASE_PATH']}/docs."} 
    end
  end
end
