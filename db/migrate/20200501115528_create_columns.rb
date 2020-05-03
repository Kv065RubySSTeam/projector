class CreateColumns < ActiveRecord::Migration[6.0]
  def change
    create_table :columns do |t|
      t.string :name
      t.integer :position, null: false, unique: true
      t.references :board, null: false, foreign_key: true
      t.timestamps
    end
  end
end
