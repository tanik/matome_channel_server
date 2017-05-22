class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.references :category, foreign_key: true
      t.references :user, foreign_key: true
      t.string :title
      t.integer :res_count, default: 0
      t.integer :score, default: 0

      t.timestamps
    end
  end
end
