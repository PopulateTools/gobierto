class AddSiteIdToGpEventsStatementsAndPosts < ActiveRecord::Migration[5.0]
  def change
    add_site_id_to_person_events
    add_site_id_to_person_statements
    add_site_id_to_person_posts
  end

  private

  def add_site_id_to_person_events
    add_column :gp_person_events, :site_id, :integer

    GobiertoPeople::PersonEvent.all.each do |event|
      event.update_column :site_id, event.person.site_id
    end

    add_foreign_key :gp_person_events, :sites
  end

  def add_site_id_to_person_statements
    add_column :gp_person_statements, :site_id, :integer

    GobiertoPeople::PersonStatement.all.each do |statement|
      statement.update_column :site_id, statement.person.site_id
    end

    add_foreign_key :gp_person_statements, :sites
  end

  def add_site_id_to_person_posts
    add_column :gp_person_posts, :site_id, :integer

    GobiertoPeople::PersonPost.all.each do |post|
      post.update_column :site_id, post.person.site_id
    end

    add_foreign_key :gp_person_posts, :sites
  end

end
