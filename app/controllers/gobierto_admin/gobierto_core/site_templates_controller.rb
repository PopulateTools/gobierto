# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class SiteTemplatesController < BaseController
      def create
        @site_template_form = SiteTemplateForm.new(site_template_params.merge(site_id: current_site.id,
                                                                              template_id: ::GobiertoCore::Template.first.id))
        @site_template_form.save
      end

      def update
        @site_template = find_site_template
        @site_template_form = SiteTemplateForm.new(
          site_template_params.merge(id: params[:id],
                                     markup: params[:site_template][:markup],
                                     site_id: @site_template.site_id,
                                     template_id: @site_template.template_id)
        )

        @site_template_form.save
      end

      private

      def site_template_params
        params.require(:site_template).permit(
          :markup,
          :site_id,
          :template_id
        )
      end

      def find_site_template
        ::GobiertoCore::SiteTemplate.find(params[:id])
      end
    end
  end
end
