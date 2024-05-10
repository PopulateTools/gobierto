class GobiertoBudgets::GenerateAnnualLinesJob < ActiveJob::Base
  queue_as :default

  def perform(*sites)
    sites.each do |site|
      if site.organization_id.present?
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.all.each do |year|
          data = GobiertoBudgets::Data::Annual.new(site: site, year: year)
          data.generate_files if data.any_data?
        end
      end
    end
  end
end
