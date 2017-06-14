class BoardScoreCalculater
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform
    current_id = 0
    loop do
      boards = Board.where(Board.arel_table[:id].gt(current_id)).order(id: :asc).limit(1000)
      break if boards.empty?
      boards.each do |board|
        board.update_score
      end
      current_id = boards.last.id
    end
  end
end
