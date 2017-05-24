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

end
