class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.float :balance, null: false, default: 0.0
      t.references :linked_owner_object, null: false, polymorphic: true

      t.timestamps
    end
  end
end
