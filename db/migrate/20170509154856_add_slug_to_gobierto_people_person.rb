class AddSlugToGobiertoPeoplePerson < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_people, :slug, :string
    ::GobiertoPeople::Person.reset_column_information
    create_slug_for_existing_people
    change_column :gp_people, :slug, :string, null: false
    add_index :gp_people, :slug, unique: true
  end

  def down
    remove_column :gp_people, :slug
  end

  private

  def create_slug_for_existing_people
    GobiertoPeople::Person.all.each do |person|
      person.send(:set_slug)
      person.save!
    end
  end

end
