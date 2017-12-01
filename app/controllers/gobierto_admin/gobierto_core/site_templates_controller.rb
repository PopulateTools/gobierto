# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class SiteTemplatesController < BaseController
      def create
        @template = find_template
        @site_template_form = SiteTemplateForm.new(site_template_params.merge(site_id: current_site.id,
                                                                              template_id: @template.id))
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

      def destroy
        @site_template = find_site_template
        @site_template_form = SiteTemplateForm.new(site_id: current_site.id,
                                                   template_id: @site_template.template_id)

        @default_template = File.read("app/views/" + @site_template.template.template_path)

        @site_template.destroy

        respond_to do |format|
          format.js { render layout: false }
        end
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

      def find_template
        ::GobiertoCore::Template.find(params[:template_id])
      end
    end
  end
end
