class AddSlugToGobiertoPeoplePersonStatement < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_person_statements, :slug, :string
    create_slug_for_existing_statements
    change_column :gp_person_statements, :slug, :string, null: false
    change_column :gp_person_statements, :published_on, :date, null: false
    add_index :gp_person_statements, :slug, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_slug_for_existing_statements
    GobiertoPeople::PersonStatement.all.each do |statement|
      statement.published_on ||= Time.zone.now.utc
      statement.send(:set_slug)
      statement.save!
    end
  end

end
