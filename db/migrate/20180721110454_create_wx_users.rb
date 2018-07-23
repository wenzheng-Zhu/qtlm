class CreateWxUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :wx_users do |t|
      t.string :open_id
      t.string :phone
      t.boolean :member
      t.decimal :bonus

      t.timestamps
    end
  end
end
