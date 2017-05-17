class AddSlugToGobiertoPeoplePersonEvent < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_person_events, :slug, :string
    create_slug_for_existing_events
    change_column :gp_person_events, :slug, :string, null: false
    change_column :gp_person_events, :starts_at, :datetime, null: false
    change_column :gp_person_events, :ends_at, :datetime, null: false
    add_index :gp_person_events, :slug, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_slug_for_existing_events
    GobiertoPeople::PersonEvent.all.each do |event|
      event.starts_at ||=  Time.zone.now.utc
      event.ends_at   ||=  (event.starts_at + 1.hour)
      event.send(:set_slug)
      event.save!
    end
  end

end
