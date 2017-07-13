namespace :gobierto_budgets do
  namespace :data do
    desc 'Dump bubbles data'
    task bubbles: :environment do
      INE::Places::Place.all.each do |place|
        url = GobiertoBudgets::Data::Bubbles.dump(place)
        puts "- Dumping bubbles data for #{place.name} - #{place.id}: #{url}"
      end
    end
  end
end
