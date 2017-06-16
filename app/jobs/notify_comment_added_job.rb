class NotifyCommentAddedJob
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform(comment_id)
    comment = Comment.find(comment_id) rescue nil
    return if comment.nil?
    BoardChannel.broadcast_to comment.board, action: :comment_added, comment: comment.to_user_params_with_board
  end
end
