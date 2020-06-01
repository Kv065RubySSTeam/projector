class AddReceiveEmailsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :receive_emails, :boolean, default: false 
  end
end
