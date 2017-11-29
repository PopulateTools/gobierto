# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class TemplatesController < BaseController
      def index
        # SiteTemplate.joins(:template).where("site_templates.site_id = ? AND templates.template_path = ?",
        #                                     current_site, template_path)
        #
        # @issue = find_issue
        # @issue_form = IssueForm.new(
        #   @issue.attributes.except(*ignored_issue_attributes)
        # )

        @site_template_form = SiteTemplateForm.new(site_id: current_site.id)

        @templates = ::GobiertoCore::Template.all
      end
    end
  end
end
