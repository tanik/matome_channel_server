class CreateCommentImages < ActiveRecord::Migration[5.1]
  def change
    create_table :comment_images do |t|
      t.references :comment, foreign_key: true
      t.references :image, foreign_key: true
    end
  end
end
