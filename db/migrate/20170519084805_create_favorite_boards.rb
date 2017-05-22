class CreateFavoriteBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :favorite_boards do |t|
      t.references :user, foreign_key: true
      t.references :board, foreign_key: true

      t.timestamps
    end
  end
end
