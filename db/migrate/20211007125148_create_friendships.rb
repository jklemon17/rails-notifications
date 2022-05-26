class CreateFriendships < ActiveRecord::Migration[6.0]
  def change
    create_table :friendships, id: :uuid do |t|
      t.belongs_to :user, index: true, type: :uuid, foreign_key: true
      t.belongs_to :friend, index: true, type: :uuid, foreign_key: {to_table: :users}
      t.integer :status, default: 0

      t.timestamps
    end
    add_index :friendships, [:user_id, :friend_id], unique: true
  end
end
