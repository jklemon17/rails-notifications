class AddTsevoStatusToUsersAndDefaultStatusToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :tsevo_status, :integer, default: 0
    change_column_default :transactions, :status, from: nil, to: 0 
  end
end
