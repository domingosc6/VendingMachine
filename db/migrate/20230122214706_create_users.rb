class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :email
      t.string :name
      t.integer :role
      t.integer :deposit
      t.string :auth_token

      t.timestamps
    end
  end
end