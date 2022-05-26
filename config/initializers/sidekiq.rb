Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS'] }
end
