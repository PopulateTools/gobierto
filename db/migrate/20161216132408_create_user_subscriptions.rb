# frozen_string_literal: true

class CreateUserSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_subscriptions do |t|
      t.references :user, index: true
      t.references :site, index: true
      t.string :subscribable_type
      t.integer :subscribable_id

      t.timestamps
    end

    add_index :user_subscriptions, [:user_id, :site_id]
    add_index :user_subscriptions, [:subscribable_type, :site_id]
    add_index :user_subscriptions, [:subscribable_type, :subscribable_id, :site_id], name: "index_user_subscriptions_on_type_and_id"
    add_index :user_subscriptions, [:subscribable_type, :subscribable_id, :site_id, :user_id], unique: true, name: "index_user_subscriptions_on_type_and_id_and_user_id"
  end
end
