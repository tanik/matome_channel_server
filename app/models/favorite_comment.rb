class FavoriteComment < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  validates :user_id, uniqueness: {scope: :comment_id}
  validates :comment_id, uniqueness: {scope: :user_id}

  # callbacks
  after_commit :notify_comment_favorited, on: :create

  private
  def notify_comment_favorited
    NotifyCommentFavoritedJob.perform_async(self.id)
  end
end
