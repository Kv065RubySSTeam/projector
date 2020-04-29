class AddIndexToMemberships < ActiveRecord::Migration[6.0]
  def change
    add_index :memberships, [:user_id, :board_id], unique: true
  end
end
