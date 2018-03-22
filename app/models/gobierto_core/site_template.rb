# frozen_string_literal: true

require_dependency "gobierto_core"

module GobiertoCore
  class SiteTemplate < ApplicationRecord
    belongs_to :template
    belongs_to :site

    def self.current_site_has_custom_template?(site, template_path)
      GobiertoCore::SiteTemplate.current_site_custom_template(site, template_path).any?
    end

    def self.current_site_custom_template(site, template_path)
      GobiertoCore::SiteTemplate.joins(:template).where("#{table_name}.site_id = ? AND gcore_templates.template_path = ?",
                                                        site.id, template_path)
    end

    def self.liquid_str(site, liquid)
      if /\A\w+\/\w+\/\w+/.match?(liquid) || /\A\w+\/\w+/.match?(liquid)
        if GobiertoCore::SiteTemplate.current_site_has_custom_template?(site, liquid)
          GobiertoCore::SiteTemplate.current_site_custom_template(site, liquid).first.markup
        elsif File.exist?("app/views/" + liquid + ".liquid")
          File.read("app/views/" + liquid + ".liquid")
        end
      else
        liquid
      end
    end
  end
end
