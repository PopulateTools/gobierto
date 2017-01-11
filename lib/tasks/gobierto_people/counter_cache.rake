namespace :gobierto_people do
  namespace :counter_cache do
    desc "Resets Person-related counter cache fields"
    task reset: :environment do
      GobiertoPeople::Person.pluck(:id).each do |person_id|
        puts "* Resetting GobiertoPeople::Person##{person_id} counters"

        GobiertoPeople::Person.reset_counters(person_id, :events)
        GobiertoPeople::Person.reset_counters(person_id, :statements)
        GobiertoPeople::Person.reset_counters(person_id, :posts)
      end
    end
  end
end
