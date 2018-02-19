class MigrateTranslatedContentToSource < ActiveRecord::Migration[5.1]
  def up
    GobiertoPeople::Person.find_each do |person|
      person.bio_source_translations = person.bio_translations
      person.save!
    end
    GobiertoPeople::PersonPost.find_each do |post|
      post.body_source = post.body
      post.save!
    end

    GobiertoCalendars::Event.find_each do |event|
      event.description_source_translations = event.description_translations
      event.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
