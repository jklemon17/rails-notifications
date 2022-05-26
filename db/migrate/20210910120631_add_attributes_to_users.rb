class AddAttributesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :order_privacy, :integer, default: 0
    remove_column :users, :name, :string
  end
end
