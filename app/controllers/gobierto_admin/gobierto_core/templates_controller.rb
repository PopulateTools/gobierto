# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class TemplatesController < BaseController
      def index
        if current_site_has_custom_template?("gobierto_participation/welcome/index.liquid")
          @site_template = current_site_custom_template("gobierto_participation/welcome/index.liquid").first
          @site_template_form = SiteTemplateForm.new(
            @site_template.attributes.except(*ignored_site_template_attributes)
          )
        else
          @site_template_form = SiteTemplateForm.new(site_id: current_site.id)
        end

        @templates = ::GobiertoCore::Template.all
      end

      private

      def ignored_site_template_attributes
        %w(created_at updated_at)
      end
    end
  end
end
