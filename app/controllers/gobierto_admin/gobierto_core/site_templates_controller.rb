# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class SiteTemplatesController < BaseController
      def create
        @template = find_template
        @site_template_form = SiteTemplateForm.new(site_template_params.merge(site_id: current_site.id,
                                                                              template_id: @template.id))
        if @site_template_form.save
          @site_template_form = SiteTemplateForm.new(
            @site_template_form.site_template.attributes.except(*ignored_site_templates_attributes)
          )
          respond_to do |format|
            format.js { flash.now[:notice] = t(".success") }
          end
        end
      end

      def update
        @site_template = find_site_template
        @site_template_form = SiteTemplateForm.new(
          site_template_params.merge(id: params[:id],
                                     markup: params[:site_template][:markup],
                                     site_id: @site_template.site_id,
                                     template_id: @site_template.template_id)
        )

        if @site_template_form.save
          respond_to do |format|
            format.js { flash.now[:notice] = t(".success") }
          end
        end
      end

      def destroy
        @site_template = find_site_template
        @site_template_form = SiteTemplateForm.new(site_id: current_site.id,
                                                   template_id: @site_template.template_id)

        @default_template = File.read("app/views/" + @site_template.template.template_path)

        if @site_template.destroy
          respond_to do |format|
            format.js { flash.now[:notice] = t(".success") }
          end
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

      def ignored_site_templates_attributes
        %w(created_at updated_at)
      end

      def find_site_template
        current_site.site_templates.find(params[:id])
      end

      def find_template
        ::GobiertoCore::Template.find(params[:template_id])
      end
    end
  end
end
