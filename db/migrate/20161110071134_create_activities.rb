# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.string :action, null: false
      t.belongs_to :subject, polymorphic: true
      t.belongs_to :author, polymorphic: true
      t.belongs_to :recipient, polymorphic: true
      t.inet :subject_ip, null: false
      t.boolean :admin_activity, null: false
      t.integer :site_id
    end

    add_index :activities, %i[subject_id subject_type]
    add_index :activities, :admin_activity
    add_index :activities, :site_id
  end
end
