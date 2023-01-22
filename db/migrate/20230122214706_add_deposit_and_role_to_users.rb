class AddDepositAndRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :deposit, :decimal
    add_column :users, :role, :string
  end
end
