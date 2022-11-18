# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :data do
    desc "Generate annual budgets data files for all sites"
    task sites_annual: :environment do
      generate_site_annual_files_for(GobiertoBudgets::Data::Annual)
    end

    desc "Generate providers and invoices annual files for all sites"
    task sites_annual_providers: :environment do
      generate_site_annual_files_for(GobiertoBudgets::Data::Providers)
    end

    def generate_site_annual_files_for(data_model)
      Site.all.each do |site|
        I18n.locale = site.configuration.default_locale
        organization_id = site.organization_id
        organization_name = site.organization_name || site.place.try(name)
        next if organization_id.nil?
        file_urls = []
        GobiertoBudgets::SearchEngineConfiguration::Year.all.each do |year|
          file_urls += data_model.new(site: site, year: year).generate_files
        end

        puts "\n- Data calculated for site #{ site.domain } and organization #{ organization_name } - #{ organization_id }: " +
          (file_urls.any? ? "#{ file_urls.count } files uploaded:" : "No files generated.")
        file_urls.each do |file_url|
          puts "\t+ #{ file_url }"
        end
      end
    end
  end
end
