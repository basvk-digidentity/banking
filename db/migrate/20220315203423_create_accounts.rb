class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :account_number, null: false
      t.decimal :balance, precision: 15, scale: 2

      t.timestamps
    end
    add_index :accounts, :account_number, unique: true

    create_join_table(:accounts, :users, null: false) do |t|
      t.index :account_id
      t.index :user_id
    end
  end
end
