class AddOneSignalIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :one_signal_id, :string
  end
end
