# frozen_string_literal: true

class RemoveDeprecatedColumnsAfterGlobalization < ActiveRecord::Migration[5.0]
  def change
    remove_column :sites, :name
    remove_column :sites, :title

    remove_column :gcms_pages, :title
    remove_column :gcms_pages, :body
    remove_column :gcms_pages, :slug

    remove_column :gp_people, :charge
    remove_column :gp_people, :bio

    remove_column :gp_person_events, :title
    remove_column :gp_person_events, :description

    remove_column :gp_person_statements, :title
  end
end
