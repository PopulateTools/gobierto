# frozen_string_literal: true

class CreateUserVerifications < ActiveRecord::Migration[5.0]
  def change
    create_table :user_verifications do |t|
      t.references :user
      t.references :site
      t.integer :verification_type, null: false, default: 0
      t.string :verification_data
      t.inet :creation_ip
      t.integer :version, null: false, default: 0
      t.boolean :verified, null: false, default: false

      t.timestamps
    end
  end
end
