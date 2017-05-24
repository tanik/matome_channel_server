class CommentImage < ApplicationRecord
  belongs_to :comment
  belongs_to :image
end
