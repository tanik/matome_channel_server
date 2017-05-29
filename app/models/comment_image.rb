class CommentImage < ApplicationRecord
  # relations
  belongs_to :comment
  belongs_to :image

  # validations
  validates :image_id, uniqueness: {scope: :comment_id}
  validates :comment_id, uniqueness: {scope: :image_id}

  # callbacks
  after_commit :notify_comment_image_added, on: :create

  def to_user_params
    {
      id: id,
      comment_id: comment_id,
      image: image.to_user_params
    }
  end
  private
  def notify_comment_image_added
    NotifyCommentImageAddedJob.perform_async(self.id)
  end
end
