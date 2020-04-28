class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.string :title
      t.text :description
      t.boolean :public, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
