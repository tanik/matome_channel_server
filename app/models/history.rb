class History < ApplicationRecord
  # relations
  belongs_to :user
  belongs_to :board

  # validations
  validates :user_id, uniqueness: {scope: :board_id}
  validates :board_id, uniqueness: {scope: :user_id}
end
