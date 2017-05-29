class Image < ApplicationRecord

  PERMITTED_CONTENT_TYPES = ["image/png", "image/x-png", "image/jpeg", "image/gif"]

  # relations
  has_many :comment_images
  has_many :comments, through: :comment_images

  # validations
  validates :original_url, presence: true, uniqueness: true

  # callbacks
  after_commit :get_image, on: :create

  def to_user_params
    {
      id: self.id,
      full_url: "#{ENV['AWS_S3_ENDPOINT']}#{self.full_url}",
      thumbnail_url: "#{ENV['AWS_S3_ENDPOINT']}#{self.thumbnail_url}",
    }
  end

  private
  def get_image
    ImageGetterJob.perform_async(self.id)
  end
end
