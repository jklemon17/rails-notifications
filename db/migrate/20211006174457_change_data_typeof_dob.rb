class ChangeDataTypeofDob < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :date_of_birth
    add_column :users, :date_of_birth, :date
  end
end
