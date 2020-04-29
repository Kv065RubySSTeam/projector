class AddIndexToBoards < ActiveRecord::Migration[6.0]
  def change
    add_index :boards, [:title, :description], unique: true
  end
end
