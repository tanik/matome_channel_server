class FavoriteBoard < ApplicationRecord
  belongs_to :board
  belongs_to :user

  validates :user_id, uniqueness: {scope: :board_id}
  validates :board_id, uniqueness: {scope: :user_id}

  # callbacks
  after_create :notify_board_favorited

  private
  def notify_board_favorited
    NotifyBoardFavoritedJob.perform_later(self.id)
  end
end
