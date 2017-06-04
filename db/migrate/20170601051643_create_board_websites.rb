class CreateBoardWebsites < ActiveRecord::Migration[5.1]
  def change
    create_table :board_websites do |t|
      t.references :board, foreign_key: true
      t.references :website, foreign_key: true
    end
  end
end
