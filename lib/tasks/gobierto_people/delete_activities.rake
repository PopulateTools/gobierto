# frozen_string_literal: true

namespace :gobierto_people do
  desc "Delete people activities on a site"
  task :delete_activities, [:site_domain] => [:environment] do |_t, args|
    site = Site.find_by!(domain: args[:site_domain])

    activities = site.activities.where(recipient_type: 'GobiertoPeople::Person')
    activities_count = activities.count
    site.activities.where(recipient_type: 'GobiertoPeople::Person').destroy_all
    puts "== Deleted #{activities_count - activities.count} people activities on site #{site.domain}"
  end
end
