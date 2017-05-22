class Board < ApplicationRecord

  # TOTO 
  # include Searchable

  # relation
  has_many :favorite_boards
  has_many :comments
  belongs_to :category
  belongs_to :user, optional: true

  # validation
  validates :title, :length => {:in => 1..255}

  # configuration keys
  CONFIGS = {
    default_name: {name: "デフォルトネーム",  default: "名無しさん。"}
  }

  def fav_count
    favorite_boards.count
  end

  def first_comment
    comments.limit(1).last.try(:content) || ""
  end

  def thumbnail_url
    # TODO
    '/images/placeholder.png'
  end

  def to_index_json
    [:id, :title, :score, :res_count, :fav_count, :first_comment, :thumbnail_url].inject({}) do |ret, key|
      ret[key] = self.send(key)
      ret
    end
  end

  def to_show_json
    hash = to_index_json
    hash[:comments] = comments.order(id: :desc).limit(20)
    hash
  end
end
