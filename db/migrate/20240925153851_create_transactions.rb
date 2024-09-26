class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.float :balance, null: false, default: 0.0
      t.bigint :wallet_id, null: true
      t.string :transaction_type, null: false
      t.string :transaction_time, null: false
      t.date :transaction_date, null: false

      t.timestamps
    end
  end
end
