# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170522101844) do

  create_table "boards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "category_id"
    t.bigint "user_id"
    t.string "title"
    t.integer "res_count", default: 0
    t.integer "score", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_boards_on_category_id"
    t.index ["user_id"], name: "index_boards_on_user_id"
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "parent_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comment_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "comment_id"
    t.bigint "image_id"
    t.index ["comment_id"], name: "index_comment_images_on_comment_id"
    t.index ["image_id"], name: "index_comment_images_on_image_id"
  end

  create_table "comment_websites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "comment_id"
    t.bigint "website_id"
    t.index ["comment_id"], name: "index_comment_websites_on_comment_id"
    t.index ["website_id"], name: "index_comment_websites_on_website_id"
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "board_id"
    t.bigint "user_id"
    t.integer "num"
    t.string "name"
    t.text "content"
    t.string "hash_id"
    t.string "remote_ip"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_comments_on_board_id"
    t.index ["hash_id"], name: "index_comments_on_hash_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "favorite_boards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_favorite_boards_on_board_id"
    t.index ["user_id"], name: "index_favorite_boards_on_user_id"
  end

  create_table "favorite_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_favorite_comments_on_comment_id"
    t.index ["user_id"], name: "index_favorite_comments_on_user_id"
  end

  create_table "images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "original_url"
    t.string "content_type"
    t.string "thumbnail_url"
    t.string "full_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["original_url"], name: "index_images_on_original_url", unique: true, length: { original_url: 255 }
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "websites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "original_url"
    t.string "title"
    t.string "thumbnail_url"
    t.string "full_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["original_url"], name: "index_websites_on_original_url", unique: true, length: { original_url: 255 }
  end

  add_foreign_key "boards", "categories"
  add_foreign_key "boards", "users"
  add_foreign_key "comment_images", "comments"
  add_foreign_key "comment_images", "images"
  add_foreign_key "comment_websites", "comments"
  add_foreign_key "comment_websites", "websites"
  add_foreign_key "comments", "boards"
  add_foreign_key "comments", "users"
  add_foreign_key "favorite_boards", "boards"
  add_foreign_key "favorite_boards", "users"
  add_foreign_key "favorite_comments", "comments"
  add_foreign_key "favorite_comments", "users"
end
