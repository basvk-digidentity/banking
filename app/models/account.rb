class Account < ApplicationRecord
    has_and_belongs_to_many :users

    validates! :account_number, presence: true, uniqueness: true, length: {maximum: 127}
    validates! :balance, presence: true, numericality: {greater_than_or_equal_to: 0}
end
