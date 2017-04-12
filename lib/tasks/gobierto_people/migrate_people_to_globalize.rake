namespace :gobierto_people do
  namespace :globalize do
    desc "Migrates people fields to globalize"
    task migrate_people: :environment do
      GobiertoPeople::Person.find_each do |person|
        puts "* Migrating person id=#{person.id}"

        I18n.available_locales.map(&:to_s).each do |locale|
          person.send "charge_#{locale}=", person.read_attribute(:charge)
          person.send "bio_#{locale}=", person.read_attribute(:bio)
        end

        person.save!

        person.events.each do |event|
          puts "* Migrating event id=#{event.id}"

          I18n.available_locales.map(&:to_s).each do |locale|
            event.send "title_#{locale}=", event.read_attribute(:title)
            event.send "description_#{locale}=", event.read_attribute(:description)
          end

          event.save!
        end

        person.statements.each do |statement|
          puts "* Migrating statement id=#{statement.id}"

          I18n.available_locales.map(&:to_s).each do |locale|
            statement.send "title_#{locale}=", statement.read_attribute(:title)
          end

          statement.save!
        end
      end
    end
  end
end
