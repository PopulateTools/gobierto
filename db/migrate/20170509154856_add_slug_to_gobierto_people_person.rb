class AddSlugToGobiertoPeoplePerson < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_people, :slug, :string
    create_slug_for_existing_people
    change_column :gp_people, :slug, :string, null: false
    add_index :gp_people, :slug, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_slug_for_existing_people
    GobiertoPeople::Person.all.each do |person|
      person.update_attributes!(
        slug: GobiertoPeople::Person.generate_unique_slug(person.name)
      )
    end
  end

end
