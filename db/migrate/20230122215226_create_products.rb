class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :productName
      t.integer :amountAvailable
      t.decimal :cost
      t.integer :sellerId

      t.timestamps
    end
  end
end
