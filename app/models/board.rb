class Board < ApplicationRecord

  include BoardSearchable

  # relation
  has_one :first_comment, ->{ order(id: :asc).limit(1) }, class_name: 'Comment'
  has_many :favorite_boards
  has_many :comments
  has_many :comment_favorites, through: :comments, source: :favorite_comments
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
    @fav_count ||= favorite_boards.count
  end

  def first_content
    first_comment.try(:content) || ""
  end

  def thumbnail_url
    super || "#{ENV["AWS_S3_ENDPOINT"]}statics/placeholder.png"
  end

  def update_score
    # 取り敢えず暫定
    new_score = comments.count * 1 +
            board_images.count * 3 +
            board_websites.count * 3 +
            comment_favorites.count * 1 +
            favorite_boards.count * 5 +
            comments.written_after(1.hours.ago).count * 100 +
            comments.written_after(12.hours.ago).count * 20 +
            comments.written_after(24.hours.ago).count * 10
    update!(score: new_score)
  end

  def to_index_params
    params = [:id, :title, :score, :res_count, :fav_count, :thumbnail_url].inject({}) do |ret, key|
      ret[key] = self.send(key)
      ret
    end
    params[:first_comment] = first_content
    params
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
