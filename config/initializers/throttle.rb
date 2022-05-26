require "redis"

REDIS = Redis.new(:url => ENV.fetch('REDIS', "redis://localhost:6379"))

THROTTLE_TIME_WINDOW = 15 * 60
THROTTLE_MAX_REQUESTS = 60
