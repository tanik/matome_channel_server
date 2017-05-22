class BoardChannel < ApplicationCable::Channel

  attr_accessor :board

  def subscribed
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def start_observe data
    self.board = Board.find(data["board_id"])
    stream_for board
  end

  def notify_add_comment comment
    self.class.broadcast_to self.board, action: :notify_add_comment, comment: comment
  end

end
