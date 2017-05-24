class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.text :original_url
      t.string :content_type
      t.string :thumbnail_url
      t.string :full_url

      t.timestamps
    end
    add_index :images, :original_url, unique: true, length: 255
  end
end
