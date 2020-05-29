class AddDiscardedAtToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :discarded_at, :datetime
    add_index :cards, :discarded_at
  end
end
