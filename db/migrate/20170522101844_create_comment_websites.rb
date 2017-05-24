class CreateCommentWebsites < ActiveRecord::Migration[5.1]
  def change
    create_table :comment_websites do |t|
      t.references :comment, foreign_key: true
      t.references :website, foreign_key: true
    end
  end
end
