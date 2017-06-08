class CommentWebsite < ApplicationRecord
  # relations
  belongs_to :comment
  belongs_to :website

  # validations
  validates :website_id, uniqueness: {scope: :comment_id}
  validates :comment_id, uniqueness: {scope: :website_id}

  def to_user_params
    {
      id: id,
      comment_id: comment_id,
      website: website.to_user_params
    }
  end
end
