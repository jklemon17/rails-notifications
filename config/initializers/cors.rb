# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins [ENV['ORIGIN'], ENV['DOMAIN']]

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: %w(Authorization)
  end
  allow do
    origins ['54.201.46.148','54.213.138.170'] # if it accepts IP addresses

    resource '/v1/transactions',
      headers: :any,
      methods: [:post] # or whatever it needs to access
  end
end
