class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.references :sender_account,   null: false, foreign_key: {to_table: :accounts}
      t.references :receiver_account, null: false, foreign_key: {to_table: :accounts}
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :remark

      t.timestamps
    end
  end
end
