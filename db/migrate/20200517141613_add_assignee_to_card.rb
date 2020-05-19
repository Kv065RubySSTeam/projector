class AddAssigneeToCard < ActiveRecord::Migration[6.0]
  def change
    add_reference :cards, :assignee, foreign_key: { to_table: 'users' }
  end
end
