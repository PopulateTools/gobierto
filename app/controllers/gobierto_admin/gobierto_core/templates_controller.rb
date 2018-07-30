# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class TemplatesController < BaseController

      before_action :check_permissions!

      def index
        template = ::GobiertoCore::Template.first
        load_site_template_variables(template)

        templates = ::GobiertoCore::Template.all
        @dir = {}

        templates.each do |paths|
          merge_paths @dir, paths.template_path.split("/")
        end
      end

      def edit
        template = find_template

        load_site_template_variables(template)
      end

      private

      def ignored_site_template_attributes
        %w(created_at updated_at)
      end

      def merge_paths(h, paths)
        top = paths[0]

        if paths.size == 1
          h[top] = top
        else
          h[top] ||= {}
          merge_paths h[top], paths[1..-1]
        end
      end

      def find_template
        ::GobiertoCore::Template.find(params[:template_id])
      end

      def load_site_template_variables(template)
        if ::GobiertoCore::SiteTemplate.current_site_has_custom_template?(current_site, template.template_path)
          @site_template = ::GobiertoCore::SiteTemplate.current_site_custom_template(current_site, template.template_path).first
          @site_template_form = SiteTemplateForm.new(
            @site_template.attributes.except(*ignored_site_template_attributes)
          )
        else
          @site_template_form = SiteTemplateForm.new(site_id: current_site.id, template_id: template.id)
        end

        @default_template = File.read("app/views/" + template.template_path + ".liquid")
      end

      def check_permissions!
        raise_module_not_allowed unless current_admin.can_edit_templates?
      end

    end
  end
end
