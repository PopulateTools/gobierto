class CreateUserNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :user_notifications do |t|
      t.references :user, index: true
      t.references :site, index: true
      t.string :action
      t.string :subject_type
      t.integer :subject_id

      t.timestamps
    end

    add_index :user_notifications, [:user_id, :site_id]
    add_index :user_notifications, [:subject_type, :subject_id, :site_id], name: "index_user_notifications_on_subject_and_site_id"
    add_index :user_notifications, [:subject_type, :subject_id, :site_id, :user_id], name: "index_user_notifications_on_subject_and_site_id_and_user_id"
  end
end
