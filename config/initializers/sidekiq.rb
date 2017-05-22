Sidekiq.configure_server do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'], namespace: 'matome-channel'}
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'], namespace: 'matome-channel'}
end
