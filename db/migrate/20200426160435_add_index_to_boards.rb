# frozen_string_literal: true

class AddIndexToBoards < ActiveRecord::Migration[6.0]
  def change
    add_index :boards, %i[title description], unique: true
  end
end
