# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Dump bubbles data for active sites"
    task bubbles_sites: :environment do
      Site.all.each do |site|
        place = site.place
        next if place.nil?
        url = GobiertoBudgets::Data::Bubbles.dump(place)
        puts "- Dumping bubbles data for #{place.name} - #{place.id}: #{url}"
      end
    end

    desc "Dump bubbles data for all INE places"
    task bubbles_all_places: :environment do
      INE::Places::Place.all.each do |place|
        url = GobiertoBudgets::Data::Bubbles.dump(place)
        puts "- Dumping bubbles data for #{place.name} - #{place.id}: #{url}"
      end
    end
  end
end
