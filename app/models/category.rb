class Category < ApplicationRecord
  # relation
  has_many :boards
  has_many :children, class_name: "Category", foreign_key: :parent_id
  belongs_to :parent, class_name: "Category", foreign_key: :parent_id, optional: true

  # validation
  validates :name, length: {in: 1..255}

  # scope
  scope :roots, ->{ where(parent_id: nil) }

  def root?
    parent.nil?
  end

  def children
    self.class.where(parent_id: self.id)
  end

  def nested_name
    nested_names.join " » "
  end

  def nested_names
    names = ["総合"]
    names << self.parent.name if self.parent
    names << self.name
    names
  end
end
