class AddNotificationFrequencyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :notification_frequency, :integer, null: false, default: 0
    add_index :users, :notification_frequency
  end
end
