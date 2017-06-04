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
    tree.map(&:name)
  end

  def tree
    categories = []
    cat = self
    loop do
      categories << cat
      cat = cat.parent
      break if cat.nil?
    end
    categories.reverse
  end

  def to_index_params
    attributes.merge(nested_name: nested_name)
  end
end
