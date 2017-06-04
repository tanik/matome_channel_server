class Image < ApplicationRecord

  PERMITTED_CONTENT_TYPES = ["image/png", "image/x-png", "image/jpeg", "image/gif"]

  # relations
  has_many :comment_images
  has_many :comments, through: :comment_images

  # validations
  validates :original_url, presence: true, uniqueness: true

  # scopes
  scope :cached, ->(){ where.not(thumbnail_url: nil, full_url: nil) }

  # callbacks
  after_commit :get_image, on: :create

  def thumbnail
    "#{ENV['AWS_S3_ENDPOINT']}#{self.thumbnail_url}"
  end

  def full
    "#{ENV['AWS_S3_ENDPOINT']}#{self.full_url}"
  end

  def to_user_params
    {
      id: self.id,
      full_url: full,
      thumbnail_url: thumbnail,
      width: width,
      height: height,
    }
  end

  private
  def get_image
    ImageGetterJob.perform_async(self.id)
  end
end
