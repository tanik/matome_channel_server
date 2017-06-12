class CreateCommentRelations < ActiveRecord::Migration[5.1]
  def change
    create_table :comment_relations do |t|
      t.references :comment, foreign_key: true
      t.references :related_comment
    end
    add_foreign_key :comment_relations, :comments, column: :related_comment_id
  end
end
