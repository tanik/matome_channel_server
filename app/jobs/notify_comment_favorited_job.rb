class NotifyCommentFavoritedJob < ApplicationJob
  queue_as :default

  def perform(favorite_comment_id)
    favorite_comment = FavoriteComment.find(favorite_comment_id) rescue nil
    return if favorite_comment.nil?
    BoardChannel.broadcast_to favorite_comment.comment.board, action: :comment_favorited, favorite: favorite_comment
  end
end
