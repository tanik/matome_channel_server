class Comment < ApplicationRecord
  # relation
  belongs_to :board
  belongs_to :user, optional: true
  has_many :favorite_comments
  has_many :favorite_users, through: :favorite_comments, source: :user
  #has_and_belongs_to_many :websites
  #has_and_belongs_to_many :images
  #has_and_belongs_to_many :movies

  # validation
  validates :name, length: {in: 0..255}
  validates :content, length: {in: 1..2048}
  #validate :check_remote_host
  #validate :check_hash_id

  # callbacks
  before_validation :complete_name, on: :create
  #before_validation :create_hash_id, on: :create
  after_create :create_num, :notify_comment_added

  def create_num
    update!(num: board.increment!(:res_count).res_count)
  end

  def complete_name
    self.name = "名無しさん" if self.name.blank?
  end

  def parse_content
    URI.extract(self.content)
  end

  private
  def notify_comment_added
    NotifyCommentAddedJob.perform_later(self.id)
  end
end
