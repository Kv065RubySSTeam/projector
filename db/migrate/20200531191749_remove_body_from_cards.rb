class RemoveBodyFromCards < ActiveRecord::Migration[6.0]
  def change
    remove_column :cards, :body, :text
  end
end
