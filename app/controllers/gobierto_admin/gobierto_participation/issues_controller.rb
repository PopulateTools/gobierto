module GobiertoAdmin
  module GobiertoParticipation
    class IssuesController < BaseController
      before_action { module_enabled!(current_site, 'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      helper_method :gobierto_participation_issue_preview_url

      def index
        @issues = current_site.issues.sorted

        @issue_form = IssueForm.new(site_id: current_site.id)
      end

      def show
        @issue = find_issue
      end

      def new
        @issue_form = IssueForm.new

        render :new_modal, layout: false and return if request.xhr?
      end

      def edit
        @issue = find_issue
        @issue_form = IssueForm.new(
          @issue.attributes.except(*ignored_issue_attributes)
        )
        @budget_lines = get_budget_lines

        render :edit_modal, layout: false and return if request.xhr?
      end

      def create
        @issue_form = IssueForm.new(
          issue_params.merge(consultation_id: @consultation.id)
        )

        if @issue_form.save
          track_create_activity

          redirect_to(
            admin_participation_issues_path(@consultation),
            notice: t(".success")
          )
        else
          render :new_modal, layout: false and return if request.xhr?
          render :new
        end
      end

      def update
        @issue = find_issue
        @issue_form = IssueForm.new(
          issue_params.merge(id: params[:id])
        )

        if @issue_form.save
          track_update_activity

          redirect_to(
            admin_participation_issues_path(@consultation),
            notice: t('.success')
          )
        else
          render :edit_modal, layout: false and return if request.xhr?
          render :edit
        end
      end

      private

      def track_create_activity
        Publishers::GobiertoParticipationIssueActivity.broadcast_event("issue_created", default_activity_params.merge({subject: @issue_form.issue}))
      end

      def track_update_activity
        Publishers::GobiertoParticipationIssueActivity.broadcast_event("issue_updated", default_activity_params.merge({subject: @issue}))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def issue_params
        params.require(:issue).permit(
          :position,
          name_translations: [*I18n.available_locales],
          slug_translations:  [*I18n.available_locales]
        )
      end

      def ignored_issue_attributes
        %w[created_at updated_at]
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
