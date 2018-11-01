unless Rails.env.payment?
  redis_config = YAML.load_file(Rails.root.join('config/redis.yml'))[Rails.env]
  h, p, d = redis_config.split(':')

  # url = "redis://#{h}"
  # url += ":#{p}" unless p.blank?
  # url += "/#{d}" unless d.blank?
  # ENV['REDIS_URL'] = url

  Redis.current = Redis.new(host: h, port: p, db: d, thread_safe: true)
  Resque.redis = Redis::Namespace.new(:resque, redis: Redis.current)
  schedule = YAML.load_file Rails.root.join('config/resque_schedule.yml')
  Resque.schedule = ActiveScheduler::ResqueWrapper.wrap schedule

  Resque.logger = Logger.new(Rails.root.join('log', "resque.log"))
  Resque.logger.level = Logger::INFO

  # https://github.com/resque/resque/wiki/Failure-Backends
  # multi-queue backend is not working properly with the web
  # require 'resque/failure/redis_multi_queue'

  require 'resque/failure/multiple'
  require 'resque/failure/redis'
  require 'resque/failure/backtrace'
  require 'resque-sentry'

  # [optional] custom logger value to use when sending to Sentry (default is 'root')
  Resque::Failure::Sentry.logger = "resque"

  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry, Resque::Failure::Backtrace]
  Resque::Failure.backend = Resque::Failure::Multiple
end
