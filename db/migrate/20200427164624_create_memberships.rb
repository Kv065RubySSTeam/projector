# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships do |t|
      t.references :board, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true, index: false
      t.boolean :admin, default: false

      t.timestamps
    end
    add_index :memberships, %i[board_id user_id], unique: true
  end
end
