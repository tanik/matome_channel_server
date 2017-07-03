require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  config.ignore_if do |exception, options|
    not Rails.env.production?
  end

  config.add_notifier :slack, {
    webhook_url: ENV['SLACK_WEBHOOK_FOR_ERROR_URL'],
    channel: "#mch_error",
    username: "mch-bot",
    additional_parameters: {
      mrkdwn: true
    }
  }
end
