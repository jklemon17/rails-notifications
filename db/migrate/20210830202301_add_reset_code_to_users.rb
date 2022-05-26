class AddResetCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reset_code, :string
  end
end
