class BoardImage < ApplicationRecord

  # relations
  belongs_to :board
  belongs_to :image

  # validations
  validates :board_id, uniqueness: {scope: :image_id}
  validates :image_id, uniqueness: {scope: :board_id}

  # callbacks
  after_commit :notify_board_image_added, on: :create

  def to_user_params
    {
      id: id,
      board_id: board_id,
      image: image.to_user_params
    }
  end

  private
  def notify_board_image_added
    NotifyBoardImageAddedJob.perform_async(self.id)
  end
end
