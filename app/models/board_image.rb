class BoardImage < ApplicationRecord

  # relations
  belongs_to :board
  belongs_to :image

  # validations
  validates :board_id, uniqueness: {scope: :image_id}
  validates :image_id, uniqueness: {scope: :board_id}

  # callbacks
  after_create :update_board_score

  # scopes
  scope :gt, ->(id){ where(arel_table[:id].gt(id)) }
  scope :lt, ->(id){ where(arel_table[:id].lt(id)) }

  def to_user_params
    {
      id: id,
      board_id: board_id,
      image: image.to_user_params
    }
  end

  private
  def update_board_score
    board.update_score
  end
end
