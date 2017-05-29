class NotifyCommentWebsiteAddedJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform(id)
    comment_website = CommentWebsite.find(id) rescue nil
    return if comment_website.nil?
    website_created = false
    30.times do
      website = comment_website.website.reload
      if website.thumbnail_url and website.full_url
        website_created = true
        break
      end
      sleep(1)
    end
    if website_created
      BoardChannel.broadcast_to comment_website.comment.board,
        action: :comment_website_added,
        comment_website: comment_website.to_user_params
    else
      raise("comment website isn't created yet.")
    end
  end
end
