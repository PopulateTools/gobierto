# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Dump bubbles data for active sites"
    task bubbles_sites: :environment do
      Site.where.not(organization_id: nil).find_each do |site|
        url = GobiertoBudgets::Data::Bubbles.dump(site)
        puts "- Dumping bubbles data for #{site.organization_name}: #{url}"
      end
    end
  end
end
