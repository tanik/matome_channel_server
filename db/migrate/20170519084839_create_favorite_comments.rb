class CreateFavoriteComments < ActiveRecord::Migration[5.1]
  def change
    create_table :favorite_comments do |t|
      t.references :user, foreign_key: true
      t.references :comment, foreign_key: true

      t.timestamps
    end
  end
end
