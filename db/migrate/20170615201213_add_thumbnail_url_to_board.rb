class AddThumbnailUrlToBoard < ActiveRecord::Migration[5.1]
  def up
    add_column :boards, :thumbnail_url, :string
    Board.all.each do |board|
      targets = []
      targets << board.images.cached.first
      targets << board.websites.cached.first
      target = targets.compact.sort{|a,b| b.created_at <=> a.created_at }.first
      board.update(thumbnail_url: target.thumbnail) if target
    end
  end

  def down
    remove_column :boards, :thumbnail_url, :string
  end
end
