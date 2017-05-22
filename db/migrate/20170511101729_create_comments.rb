class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :board, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :num
      t.string :name
      t.text :content
      t.string :hash_id
      t.string :remote_ip
      t.string :user_agent

      t.timestamps
    end
    add_index :comments, :hash_id
  end
end
