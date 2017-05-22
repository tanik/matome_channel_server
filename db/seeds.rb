# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
({
  "社会" => ["社会", "政治", "経済"],
  "暮らし" => ["生活", "人生"],
  "エンターテイメント" => ["スポーツ", "音楽", "芸能"],
  "学ぶ" => ["科学", "学問"],
  "コンピュータ" => ["コンピュータ・IT", "ハード", "ソフト"],
  "サブカルチャー" => ["アニメ", "ゲーム"],
  "おもしろ" => ["ネタ", "オカルト"],
}).each do |k,v|
  p = Category.create!(name: k)
  v.each do |n|
    Category.create!(parent: p, name: n)
  end
end
categories = Category.all
50.times do |i|
  board = Board.create(category: categories.sample, title: "Board title #{i+1}")
  100.times do |j|
    board.comments.create(name: "名無しさん", content: "Board##{board.id}\nComment ##{j}")
  end
end
