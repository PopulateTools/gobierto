# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Generate annual budgets data files for all sites"
    task sites_annual: :environment do
      Site.all.each do |site|
        place = site.place
        next if place.nil?
        file_urls = []
        GobiertoBudgets::SearchEngineConfiguration::Year.all.each do |year|
          file_urls += GobiertoBudgets::Data::Annual.new(site: site, year: year).generate_files
        end

        puts "\n- Data calculated for site #{site.domain} and place #{place.name} - #{place.id}: " +
          (file_urls.any? ? "#{file_urls.count} files uploaded:" : "No files generated.")
        file_urls.each do |file_url|
          puts "\t+ #{file_url}"
        end
      end
    end
  end
end
