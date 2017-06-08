class CommentImage < ApplicationRecord
  # relations
  belongs_to :comment
  belongs_to :image

  # validations
  validates :image_id, uniqueness: {scope: :comment_id}
  validates :comment_id, uniqueness: {scope: :image_id}

  def to_user_params
    {
      id: id,
      comment_id: comment_id,
      image: image.to_user_params
    }
  end
end
