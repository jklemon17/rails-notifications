source "https://rubygems.org"

ruby "2.7.4"
# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 6.0.3"
# Use postgresql as the database for Active Record
gem "pg"

# Use Puma as the app server
# gem "puma", "~> 3.0"
gem "puma"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 3.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

gem "httparty"
gem "httpclient"
gem "aws-sdk-s3"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"
gem "rack-attack"

# Serializing JSON
gem "jsonapi-serializer"

#For Active Admin
gem 'activeadmin'
gem 'activeadmin_addons'
gem "sass-rails"
gem 'country_select', '~> 4.0'
gem 'devise'
gem "devise-jwt"

# Sentry for error telemetry
gem "sentry-ruby"
gem "sentry-rails"

gem "swagger-blocks"

gem "redis"
gem "sidekiq"
gem 'sidekiq-scheduler'

gem "dotenv-rails"
gem 'sendgrid-ruby'
gem "awesome_print"
gem "mina"
gem "wdm", ">= 0.1.0" if Gem.win_platform?
gem 'nio4r', '= 2.5.7'

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  # Use RSpec for specs
  gem "rspec-rails"
  # Use Factory Bot for generating random test data
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "listen", "~> 3.0.5"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

