class NotifyCommentImageAddedJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform(id)
    comment_image = CommentImage.find(id) rescue nil
    return if comment_image.nil?
    image_created = false
    30.times do
      image = comment_image.image.reload
      if image.thumbnail_url and image.full_url
        image_created = true
        break
      end
      sleep(1)
    end
    if image_created
      BoardChannel.broadcast_to comment_image.comment.board,
        action: :comment_image_added,
        comment_image: comment_image.to_user_params
    else
      raise("comment image isn't created yet.")
    end
  end
end
