Sidekiq.configure_server do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'], namespace: 'matome-channel'}
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'], namespace: 'matome-channel'}
end

# settings for sidekiq-cron
schedule_file = "config/schedule.yml"

if File.exists?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
