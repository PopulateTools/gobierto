class ScopeSlugIndexesOnSite < ActiveRecord::Migration[5.1]

  def up
    add_index :collections, [:site_id, :slug], unique: true
    add_index :ga_attachments, [:site_id, :slug], unique: true
    add_index :gcms_pages, [:site_id, :slug], unique: true
    add_index :gcms_sections, [:site_id, :slug], unique: true

    remove_index :gobierto_calendars_events, name: 'index_gobierto_calendars_events_on_slug'
    add_index :gobierto_calendars_events, [:site_id, :slug], unique: true

    remove_index :gp_people, name: 'index_gp_people_on_slug'
    add_index :gp_people, [:site_id, :slug], unique: true

    remove_index :gp_person_posts, name: 'index_gp_person_posts_on_slug'
    add_index :gp_person_posts, [:site_id, :slug], unique: true

    remove_index :gp_person_statements, name: 'index_gp_person_statements_on_slug'
    add_index :gp_person_statements, [:site_id, :slug], unique: true

    add_index :gpart_contribution_containers, [:site_id, :slug], unique: true
    add_index :gpart_contributions, [:site_id, :slug], unique: true

    remove_index :gpart_processes, name: 'index_gpart_processes_on_slug'
    add_index :gpart_processes, [:site_id, :slug], unique: true

    add_index :issues, [:site_id, :slug], unique: true
  end

  def down
    remove_index :collections, name: 'index_collections_on_site_id_and_slug'
    remove_index :ga_attachments, name: 'index_ga_attachments_on_site_id_and_slug'
    remove_index :gcms_pages, name: 'index_gcms_pages_on_site_id_and_slug'
    remove_index :gcms_sections, name: 'index_gcms_sections_on_site_id_and_slug'

    remove_index :gobierto_calendars_events, name: 'index_gobierto_calendars_events_on_site_id_and_slug'
    add_index :gobierto_calendars_events, :slug, unique: true

    remove_index :gp_people, name: 'index_gp_people_on_site_id_and_slug'
    add_index :gp_people, :slug, unique: true

    remove_index :gp_person_posts, name: 'index_gp_person_posts_on_site_id_and_slug'
    add_index :gp_person_posts, :slug, unique: true

    remove_index :gp_person_statements, name: 'index_gp_person_statements_on_site_id_and_slug'
    add_index :gp_person_statements, :slug, unique: true

    remove_index :gpart_contribution_containers, name: 'index_gpart_contribution_containers_on_site_id_and_slug'
    remove_index :gpart_contributions, name: 'index_gpart_contributions_on_site_id_and_slug'

    remove_index :gpart_processes, name: 'index_gpart_processes_on_site_id_and_slug'
    add_index :gpart_processes, :slug, unique: true

    remove_index :issues, name: 'index_issues_on_site_id_and_slug'
  end

end
