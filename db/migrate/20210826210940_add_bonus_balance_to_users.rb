class AddBonusBalanceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bonus_balance, :integer, :default => 0
  end
end
