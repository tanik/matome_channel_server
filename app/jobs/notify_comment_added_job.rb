class NotifyCommentAddedJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id) rescue nil
    return if comment.nil?
    BoardChannel.broadcast_to comment.board, action: :comment_added, comment: comment
  end
end
