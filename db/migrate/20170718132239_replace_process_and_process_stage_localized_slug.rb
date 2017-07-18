class ReplaceProcessAndProcessStageLocalizedSlug < ActiveRecord::Migration[5.1]

  def change
    update_processes_table_slug
    update_process_stages_table_slug
  end

  def update_processes_table_slug
    remove_index :gpart_processes, name: 'index_gpart_processes_on_slug_translations'
    remove_column :gpart_processes, :slug_translations
    add_index :gpart_processes, :slug, unique: true
  end

  def update_process_stages_table_slug
    add_column :gpart_process_stages, :slug, :string, null: false
    add_index :gpart_process_stages, :slug, unique: true

    remove_index :gpart_process_stages, name: 'index_gpart_process_stages_on_slug_translations'
    remove_column :gpart_process_stages, :slug_translations
  end

end
