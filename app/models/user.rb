class User < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :accounts

  validates :login, presence: true, uniqueness: true, length: {maximum: 127}
  validates :password, presence: true, length: {within: 8..127}, confirmation: true
end
