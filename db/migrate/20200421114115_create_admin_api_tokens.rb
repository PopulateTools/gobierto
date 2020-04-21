# frozen_string_literal: true

class CreateAdminApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_api_tokens do |t|
      t.references :admin
      t.string :name
      t.string :token
      t.boolean :primary, default: false

      t.timestamps
    end

    add_index :admin_api_tokens, :token, unique: true

    GobiertoAdmin::Admin.all.each(&:primary_api_token!)
  end
end
