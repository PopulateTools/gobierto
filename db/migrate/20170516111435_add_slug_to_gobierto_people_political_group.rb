class AddSlugToGobiertoPeoplePoliticalGroup < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_political_groups, :slug, :string
    create_slug_for_existing_political_groups
    change_column :gp_political_groups, :slug, :string, null: false
    add_index :gp_political_groups, :slug, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_slug_for_existing_political_groups
    GobiertoPeople::PoliticalGroup.all.each do |political_group|
      political_group.update_attributes!(
        slug: GobiertoPeople::PoliticalGroup.generate_unique_slug(political_group.name)
      )
    end
  end

end
