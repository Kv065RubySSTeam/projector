class AddStartDateAndDurationToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :start_date, :date
    add_column :cards, :duration, :integer, default: 0
  end
end
