# frozen_string_literal: true

class AddBodySourceToProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :gpart_processes, :body_source_translations, :jsonb
    add_index :gpart_processes, :body_source_translations, using: :gin
  end
end
