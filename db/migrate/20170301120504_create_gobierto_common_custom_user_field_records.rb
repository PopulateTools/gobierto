class CreateGobiertoCommonCustomUserFieldRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_user_field_records do |t|
      t.references :user
      t.references :custom_user_field
      t.jsonb :payload

      t.timestamps
    end

    add_index :custom_user_field_records, :payload, using: :gin
  end
end
