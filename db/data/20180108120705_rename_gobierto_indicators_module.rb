# frozen_string_literal: true

class RenameGobiertoIndicatorsModule < ActiveRecord::Migration[5.1]
  def up
    Site.all.each do |site|
      modules = site.configuration_data["modules"]

      if modules.include?("GobiertoIndicators")
        modules = modules.append("GobiertoObservatory")
        modules.delete("GobiertoIndicators")
        site.configuration_data["modules"] = modules

        if site.configuration.home_page == "GobiertoIndicators"
          site.configuration.home_page = site.configuration.home_page.gsub("GobiertoIndicators", "GobiertoObservatory")
        end
        site.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
