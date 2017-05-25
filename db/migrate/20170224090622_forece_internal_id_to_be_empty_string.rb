# frozen_string_literal: true

class ForeceInternalIdToBeEmptyString < ActiveRecord::Migration[5.0]
  def up
    remove_index :content_blocks, name: 'index_content_blocks_on_site_id_and_internal_id'
    change_column_default :content_blocks, :internal_id, from: nil, to: ''
    change_column_null :content_blocks, :internal_id, from: true, to: false
    GobiertoCommon::ContentBlock.where(internal_id: nil).each do |cb|
      cb.update_column :internal_id, ''
    end
  end

  def down
    add_index :content_blocks, %i[site_id internal_id], name: 'index_content_blocks_on_site_id_and_internal_id'
    change_column_default :content_blocks, :internal_id, from: '', to: nil
    change_column_null :content_blocks, :internal_id, from: false, to: true
  end
end
