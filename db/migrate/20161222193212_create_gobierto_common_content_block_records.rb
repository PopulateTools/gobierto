class CreateGobiertoCommonContentBlockRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :content_block_records do |t|
      t.references :content_block
      t.references :content_context, polymorphic: true, index: { name: "index_content_block_records_on_content_context" }
      t.jsonb :payload

      t.timestamps
    end

    add_index :content_block_records, :payload, using: :gin
  end
end
