class CreateWebsites < ActiveRecord::Migration[5.1]
  def change
    create_table :websites do |t|
      t.text :original_url
      t.string :title
      t.string :thumbnail_url
      t.string :full_url

      t.timestamps
    end
    add_index :websites, :original_url, unique: true, length: 255
  end
end
