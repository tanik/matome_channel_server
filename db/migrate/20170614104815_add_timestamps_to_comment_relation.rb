class AddTimestampsToCommentRelation < ActiveRecord::Migration[5.1]
  def change
    add_timestamps(:comment_relations)
  end
end
