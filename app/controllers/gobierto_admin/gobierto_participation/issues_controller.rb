module GobiertoAdmin
  module GobiertoParticipation
    class IssuesController < BaseController
      before_action { module_enabled!(current_site, 'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      helper_method :gobierto_participation_issue_preview_url

      def index
        @issues = current_site.issues.sorted
      end

      private

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def issue_params
        params.require(:issue).permit(
          name_translations: [*I18n.available_locales],
          slug_translations:  [*I18n.available_locales]
        )
      end

      def ignored_issue_attributes
        %w[created_at updated_at slug]
      end

      def find_issue
        current_site.issues.find(params[:id])
      end

      def gobierto_participation_issue_preview_url(issue, options = {})
        options[:preview_token] = current_admin.preview_token unless issue.active?
        gobierto_participation_issue_url(issue.slug, options)
      end
    end
  end
end
