class FavoriteBoard < ApplicationRecord
  belongs_to :board
  belongs_to :user

  validates :user_id, uniqueness: {scope: :board_id}
  validates :board_id, uniqueness: {scope: :user_id}
end
