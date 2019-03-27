# frozen_string_literal: true

class AddTemplateToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :gcms_pages, :template, :string
  end
end
