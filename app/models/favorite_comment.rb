class FavoriteComment < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  validates :user_id, uniqueness: {scope: :comment_id}
  validates :comment_id, uniqueness: {scope: :user_id}

  # callbacks
  after_create :update_board_score
  after_commit :notify_comment_favorited, on: :create

  private
  def update_board_score
    comment.board.update_score
  end

  def notify_comment_favorited
    NotifyCommentFavoritedJob.perform_async(self.id)
  end
end
