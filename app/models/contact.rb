class Contact < ApplicationRecord
  validates :email, presence: true, email: true
  validates :content, length: {in: 1..65535}

  after_create :notify_by_slack

  private
  def notify_by_slack
    notifier = Slack::Notifier.new(ENV['SLACK_WEBHOOK_FOR_CONTACT_URL']) do
    end
    message =<<~EOS
      メールアドレス:
      #{email}

      問い合わせ内容:
      #{content}
    EOS
    notifier.ping text: message
  end
end
