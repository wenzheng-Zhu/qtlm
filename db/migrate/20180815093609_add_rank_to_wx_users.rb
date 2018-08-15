class AddRankToWxUsers < ActiveRecord::Migration[5.2]
  def change

  	add_column :wx_users, :rank, :string
  end
end
