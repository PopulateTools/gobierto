# frozen_string_literal: true

class AddSiteIdToGpEventsStatementsAndPosts < ActiveRecord::Migration[5.0]
  def up
    add_site_id_to_person_events
    add_site_id_to_person_statements
    add_site_id_to_person_posts
  end

  def down
    remove_column :gp_person_events, :site_id
    remove_column :gp_person_statements, :site_id
    remove_column :gp_person_posts, :site_id
  end

  private

  def add_site_id_to_person_events
    add_column :gp_person_events, :site_id, :integer
    add_foreign_key :gp_person_events, :sites
    change_column :gp_person_events, :site_id, :integer, null: false
  end

  def add_site_id_to_person_statements
    add_column :gp_person_statements, :site_id, :integer

    GobiertoPeople::PersonStatement.all.each do |statement|
      statement.update_column :site_id, statement.person.site_id
    end

    add_foreign_key :gp_person_statements, :sites
    change_column :gp_person_statements, :site_id, :integer, null: false
  end

  def add_site_id_to_person_posts
    add_column :gp_person_posts, :site_id, :integer

    GobiertoPeople::PersonPost.all.each do |post|
      post.update_column :site_id, post.person.site_id
    end

    add_foreign_key :gp_person_posts, :sites
    change_column :gp_person_posts, :site_id, :integer, null: false
  end
end
