class BoardWebsite < ApplicationRecord

  # relations
  belongs_to :board
  belongs_to :website

  # relations
  validates :board_id, uniqueness: {scope: :website_id}
  validates :website_id, uniqueness: {scope: :board_id}

  # callbacks
  after_create :update_board_score

  def to_user_params
    {
      id: id,
      board_id: board_id,
      website: website.to_user_params
    }
  end

  private
  def update_board_score
    board.update_score
  end
end
