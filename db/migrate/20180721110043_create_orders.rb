class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :open_id
      t.decimal :total_price
      t.decimal :sum_price
      t.text :stuff

      t.timestamps
    end
  end
end
