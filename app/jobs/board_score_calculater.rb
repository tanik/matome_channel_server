class BoardScoreCalculater
  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: false

  def perform
    current_id = 0
    an_hour_ago = 1.hours.ago
    a_day_ago = 25.hours.ago
    loop do
      # 24時間以上経過するとscoreに変化はなくなるはずなので更新がない1-25時間を対象にする
      boards = Board.where(Board.arel_table[:updated_at].lt(an_hour_ago)).
        where(Board.arel_table[:updated_at].gt(a_day_ago)).
        where(Board.arel_table[:id].gt(current_id)).order(id: :asc).limit(1000)
      break if boards.empty?
      boards.each do |board|
        board.update_score
      end
      current_id = boards.last.id
    end
  end
end
