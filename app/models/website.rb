class Website < ApplicationRecord

  PERMITTED_CONTENT_TYPES = ["text/html", "text/plain"]

  # relations
  has_many :comment_websites
  has_many :comments, through: :comment_websites

  # validations
  validates :original_url, presence: true, uniqueness: true

  # callbacks
  after_commit :create_webshot, on: :create

  def to_user_params
    {
      id: self.id,
      title: self.title,
      original_url: original_url,
      full_url: "#{ENV['AWS_S3_ENDPOINT']}#{self.full_url}",
      thumbnail_url: "#{ENV['AWS_S3_ENDPOINT']}#{self.thumbnail_url}",
    }
  end

  private
  def create_webshot
    WebshotCreatorJob.perform_async(self.id)
  end
end
