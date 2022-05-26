Sentry.init do |config|
  config.dsn = 'https://2ce515a7ff5f45f0a6a672e23dd84bbf@o282181.ingest.sentry.io/6012647'

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.enabled_environments = %w[production staging]

  config.traces_sample_rate = Rails.env.production? ? 0 : 0.5
end
