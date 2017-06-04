class CreateBoardImages < ActiveRecord::Migration[5.1]
  def change
    create_table :board_images do |t|
      t.references :board, foreign_key: true
      t.references :image, foreign_key: true
    end
  end
end
