class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable,
          :validatable #,:confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  # relations
  has_many :boards
  has_many :comments
  has_many :favorite_boards
  has_many :favorite_comments
end
