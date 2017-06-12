class CommentRelation < ApplicationRecord
  belongs_to :comment
  belongs_to :related_comment, class_name: :Comment

  # validations
  validates :comment_id, uniqueness: {scope: :related_comment_id}
  validates :related_comment_id, uniqueness: {scope: :comment_id}
end
