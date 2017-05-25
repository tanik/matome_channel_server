class NotifyBoardFavoritedJob < ApplicationJob
  queue_as :default

  def perform(favorite_board_id)
    favorite_board = FavoriteBoard.find(favorite_board_id) rescue nil
    return if favorite_board.nil?
    BoardChannel.broadcast_to favorite_board.board, action: :board_favorited, favorite: favorite_board
  end
end
