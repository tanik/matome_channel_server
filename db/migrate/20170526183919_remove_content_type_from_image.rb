class RemoveContentTypeFromImage < ActiveRecord::Migration[5.1]
  def change
    remove_column :images, :content_type, :string
  end
end
