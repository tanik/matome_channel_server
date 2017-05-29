class CommentWebsite < ApplicationRecord
  # relations
  belongs_to :comment
  belongs_to :website

  # validations
  validates :website_id, uniqueness: {scope: :comment_id}
  validates :comment_id, uniqueness: {scope: :website_id}

  # callbacks
  after_commit :notify_comment_website_added, on: :create

  def to_user_params
    {
      id: id,
      comment_id: comment_id,
      website: website.to_user_params
    }
  end

  private
  def notify_comment_website_added
    NotifyCommentWebsiteAddedJob.perform_async(self.id)
  end
end
