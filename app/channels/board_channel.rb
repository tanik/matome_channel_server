class BoardChannel < ApplicationCable::Channel

  attr_accessor :boards

  def subscribed
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def start_observe data
    self.boards = Board.find(data["board_id"])
    stream_for boards
  end

  def start_observe_favorites data
    self.boards = User.find(data["user_id"]).favorite_boards.map(&:board)
    boards.each do |board|
      stream_for board
    end
  end
end
