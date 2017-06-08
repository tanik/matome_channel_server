class Website < ApplicationRecord

  PERMITTED_CONTENT_TYPES = ["text/html", "text/plain"]

  # relations
  has_many :comment_websites
  has_many :comments, through: :comment_websites

  # validations
  validates :original_url, presence: true, uniqueness: true

  # scopes
  scope :cached, ->(){ where.not(title:nil, thumbnail_url: nil, full_url: nil) }

  def thumbnail
    "#{ENV['AWS_S3_ENDPOINT']}#{self.thumbnail_url}"
  end

  def full
    "#{ENV['AWS_S3_ENDPOINT']}#{self.full_url}"
  end

  def to_user_params
    {
      id: self.id,
      title: self.title,
      original_url: original_url,
      full_url: full,
      thumbnail_url: thumbnail,
    }
  end
end
