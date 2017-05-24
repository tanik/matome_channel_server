class Website < ApplicationRecord

  PERMITTED_CONTENT_TYPES = ["text/html", "text/plain"]

  # relations
  has_many :comment_websites
  has_many :comments, through: :comment_websites

  # validations
  validates :original_url, presence: true, uniqueness: true
  validates :title, length: {in: 0..255}
end
