# frozen_string_literal: true

class SetSiteHomePage < ActiveRecord::Migration[5.1]
  def up
    Site.all.each do |site|
      if site.configuration.modules.include?("GobiertoPeople")
        site.configuration.home_page = "GobiertoPeople"
      elsif site.configuration.modules.include?("GobiertoBudgets")
        site.configuration.home_page = "GobiertoBudgets"
      elsif site.configuration.modules.include?("GobiertoParticipation")
        site.configuration.home_page = "GobiertoParticipation"
      elsif site.configuration.modules.include?("GobiertoIndicators")
        site.configuration.home_page = "GobiertoIndicators"
      end
      site.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
