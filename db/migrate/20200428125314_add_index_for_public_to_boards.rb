class AddIndexForPublicToBoards < ActiveRecord::Migration[6.0]
  def change
    add_index :boards, :public
	end 
end
