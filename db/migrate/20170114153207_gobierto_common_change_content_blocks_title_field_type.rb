class GobiertoCommonChangeContentBlocksTitleFieldType < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'hstore' unless extension_enabled?('hstore')

    add_column :content_blocks, :title_hstore, :hstore

    ActiveRecord::Base.transaction do
      GobiertoCommon::ContentBlock.select(:id, :title).find_each do |content_block|
        content_block.update_columns(title_hstore: YAML::load(content_block.title))
      end
    end

    remove_column :content_blocks, :title
    rename_column :content_blocks, :title_hstore, :title
  end

  def down
    add_column :content_blocks, :title_text, :text

    ActiveRecord::Base.transaction do
      GobiertoCommon::ContentBlock.select(:id, :title).find_each do |content_block|
        content_block.update_columns(title_text: YAML::dump(content_block.title))
      end
    end

    remove_column :content_blocks, :title
    rename_column :content_blocks, :title_text, :title
  end
end
