class Comment < ApplicationRecord

  HASH_SECRET = ENV['HASH_SECRET']
  HASH_LENGTH = 16

  # relation
  belongs_to :board
  belongs_to :user, optional: true
  has_many :favorite_comments
  has_many :favorite_users, through: :favorite_comments, source: :user
  has_many :comment_websites
  has_many :websites, through: :comment_websites
  has_many :comment_images
  has_many :images, through: :comment_images
  has_many :comment_relations
  has_many :anchor_comments, through: :comment_relations, source: :related_comment
  has_many :from_comment_relations, class_name: 'CommentRelation', foreign_key: :related_comment_id
  has_many :anchored_comments, through: :from_comment_relations, source: :comment
  #has_many :comment_movies
  #has_many :movies, through: :comment_movies

  # scopes
  scope :gt, ->(id){ where(arel_table[:id].gt(id)) }
  scope :lt, ->(id){ where(arel_table[:id].lt(id)) }
  scope :written_after, ->(written_at){ where(arel_table[:created_at].gteq(written_at)) }
  scope :num_gteq, ->(num){ where(arel_table[:num].gteq(num)) }
  scope :num_lteq, ->(num){ where(arel_table[:num].lteq(num)) }

  # validation
  validates :name, length: {in: 1..255}
  validates :content, length: {in: 1..2048}

  # callbacks
  before_validation :complete_name, on: :create
  before_validation :create_hash_id, on: :create
  after_create :create_num
  after_commit :update_board_score, :notify_comment_added, :parse_content, :update_board_index,  on: :create

  def to_user_params
    params = [:id, :user_id, :board_id, :num, :name, :content, :created_at, :hash_id].inject({}) do |ret, key|
      ret[key] = self.send(key)
      ret
    end
    params[:websites] = websites.map(&:to_user_params)
    params[:images] = images.map(&:to_user_params)
    params[:favorite_user_ids] = favorite_comments.map(&:user_id)
    params
  end

  def all_related_comments
    (anchor_comments.to_a + anchored_comments.to_a).sort{|a,b| b.id <=> a.id }
  end

  private
  def create_num
    update!(num: board.increment!(:res_count).res_count)
  end

  def update_board_score
    board.update_score
  end

  def complete_name
    self.name = "名無しさん" if self.name.blank?
  end

  def create_hash_id
    date = created_at.try(:to_date)
    date ||= Date.today
    digest = Base64.encode64(Digest::SHA1.digest("#{HASH_SECRET}#{date}#{remote_ip}#{user_agent}"))
    self.hash_id = digest[0...HASH_LENGTH]
  end

  def parse_content
    CommentParser.perform_async(self.id)
  end

  def notify_comment_added
    NotifyCommentAddedJob.perform_async(self.id)
  end

  def update_board_index
    BoardIndexer.perform_async('update', self.board_id)
  end
end
