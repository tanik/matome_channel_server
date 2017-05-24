class CommentWebsite < ApplicationRecord
  belongs_to :comment
  belongs_to :website
end
