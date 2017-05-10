class AddSlugToGobiertoPeoplePersonEvent < ActiveRecord::Migration[5.0]

  def up
    add_column :gp_person_events, :slug, :string
    create_slug_for_existing_events
    change_column :gp_person_events, :slug, :string, null: false
    change_column :gp_person_events, :starts_at, :date, null: false
    change_column :gp_person_events, :ends_at, :date, null: false
    add_index :gp_person_events, :slug, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_slug_for_existing_events
    GobiertoPeople::PersonEvent.all.each do |event|
      starts_at = event.starts_at || Time.zone.now.utc
      ends_at = event.ends_at || starts_at + 1.hour
      event.update_attributes!(
        slug: GobiertoPeople::PersonEvent.generate_unique_slug(event.title_with_fallback, starts_at),
        starts_at: starts_at,
        ends_at: ends_at
      )
    end
  end

end
