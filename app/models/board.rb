class Board < ApplicationRecord

  include BoardSearchable

  # relation
  has_many :favorite_boards
  has_many :comments
  belongs_to :category
  belongs_to :user, optional: true
  has_many :board_images, ->(){ order(id: :desc) }
  has_many :images, through: :board_images
  has_many :board_websites, ->(){ order(id: :desc) }
  has_many :websites, through: :board_websites
  accepts_nested_attributes_for :comments

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
    targets = []
    targets << images.cached.first
    targets << websites.cached.first
    target = targets.compact.sort{|a,b| b.created_at <=> a.created_at }.first
    if target
      target.thumbnail
    else
      "#{ENV["AWS_S3_ENDPOINT"]}statics/placeholder.png"
    end
  end

  def to_index_params
    [:id, :title, :score, :res_count, :fav_count, :first_comment, :thumbnail_url].inject({}) do |ret, key|
      ret[key] = self.send(key)
      ret
    end
  end

  def to_show_params
    hash = to_index_params
    hash[:category_tree] = category.tree
    hash[:websites] = board_websites.includes(:website).limit(20).map(&:to_user_params)
    hash[:images] = board_images.includes(:image).limit(20).map(&:to_user_params)
    hash[:favorite_user_ids] = favorite_boards.map(&:user_id)
    hash[:comments] = comments.includes([
      :favorite_comments,
      :images,
      :websites,
    ]).order(id: :desc).limit(20).map(&:to_user_params)
    hash
  end
end
