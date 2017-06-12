class AddBoardIdAndNumIndexToComment < ActiveRecord::Migration[5.1]
  def change
    add_index :comments, [:board_id, :num]
  end
end
