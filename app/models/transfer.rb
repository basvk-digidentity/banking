class Transfer < ApplicationRecord
  belongs_to :sender_account, class_name: 'Account'
  belongs_to :receiver_account, class_name: 'Account'

  validates :amount, numericality: {greater_than: 0}
  validates :remark, length: {maximum: 127}

  validate :sender_is_not_receiver
  validate :amount_not_greater_than_balance

  def sender_is_not_receiver
    errors.add(:base, 'sender and receiver account must differ') if sender_account == receiver_account
  end

  def amount_not_greater_than_balance
    errors.add(:base, 'there are insufficient funds in the account') if (amount || 0) > sender_account.balance
  end
end
