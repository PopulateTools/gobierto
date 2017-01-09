class CreateGobiertoCommonContentBlockFields < ActiveRecord::Migration[5.0]
  def change
    create_table :content_block_fields do |t|
      t.references :content_block
      t.integer :field_type, null: false, default: 0
      t.string :name, null: false, default: ""
      t.text :label
      t.integer :position, null: false, default: 0
    end
  end
end
