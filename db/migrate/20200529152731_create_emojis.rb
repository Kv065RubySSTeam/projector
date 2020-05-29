class CreateEmojis < ActiveRecord::Migration[6.0]
  def change
    create_table :emojis do |t|
      t.references :user, null: false, foreign_key: true
      t.references :emojible, polymorphic: true, null: false

      t.timestamps
    end
  end
end
