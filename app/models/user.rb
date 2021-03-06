class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable,
          :validatable #,:confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  # relations
  has_many :boards
  has_many :comments
  has_many :favorite_boards
  has_many :my_favorite_boards, through: :favorite_boards, source: :board
  has_many :favorite_comments
  has_many :my_favorite_comments, through: :favorite_comments, source: :comment
  has_many :histories

  def add_history board
    histories.find_by(board_id: board.id).try(:destroy)
    histories.create(board: board)
    new_histories = histories.order(id: :desc).to_a
    if new_histories.size > History::MAX_PER_USER
      History.where(id: new_histories[History::MAX_PER_USER..-1].map(&:id)).delete_all
    end
  end
end
