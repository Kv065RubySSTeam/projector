class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :type
      t.references :notificationable, polymorphic: true, null: false, index: { name: :index_on_notificationable_type_and_notificationable_id }

      t.timestamps
    end
  end
end
