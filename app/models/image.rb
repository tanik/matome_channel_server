class Image < ApplicationRecord

  PERMITTED_CONTENT_TYPES = ["image/png", "image/x-png", "image/jpeg", "image/gif"]

  # relations
  has_many :comment_images
  has_many :comments, through: :comment_images

  # validations
  validates :original_url, presence: true, uniqueness: true
  validates :content_type, presence: true, inclusion: PERMITTED_CONTENT_TYPES
end
