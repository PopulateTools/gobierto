# frozen_string_literal: true

module GobiertoAdmin
  class IssuesController < BaseController
    helper_method :issue_preview_url

    def index
      @issues = current_site.issues.sorted

      @issue_form = IssueForm.new(site_id: current_site.id)
    end

    def show
      @issue = find_issue
    end

    def new
      @issue_form = IssueForm.new

      render(:new_modal, layout: false) && return if request.xhr?
    end

    def edit
      @issue = find_issue
      @issue_form = IssueForm.new(
        @issue.attributes.except(*ignored_issue_attributes)
      )

      render(:edit_modal, layout: false) && return if request.xhr?
    end

    def create
      @issue_form = IssueForm.new(issue_params.merge(site_id: current_site.id))

      if @issue_form.save
        track_create_activity

        redirect_to(
          admin_issues_path(@issue),
          notice: t(".success_html", link: gobierto_participation_issue_url(@issue_form.issue.slug, host: current_site.domain))
        )
      else
        render(:new_modal, layout: false) && return if request.xhr?
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
          admin_issues_path(@issue),
          notice: t(".success_html", link: gobierto_participation_issue_url(@issue_form.issue.slug, host: current_site.domain))
        )
      else
        render(:edit_modal, layout: false) && return if request.xhr?
        render :edit
      end
    end

    private

    def track_create_activity
      Publishers::IssueActivity.broadcast_event("issue_created", default_activity_params.merge(subject: @issue_form.issue))
    end

    def track_update_activity
      Publishers::IssueActivity.broadcast_event("issue_updated", default_activity_params.merge(subject: @issue))
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin, site_id: current_site.id }
    end

    def issue_params
      params.require(:issue).permit(
        :slug,
        name_translations: [*I18n.available_locales],
        description_translations: [*I18n.available_locales]
      )
    end

    def ignored_issue_attributes
      %w(position created_at updated_at)
    end

    def find_issue
      current_site.issues.find(params[:id])
    end

    def issue_preview_url(issue, options = {})
      options[:preview_token] = current_admin.preview_token unless issue.active?
      gobierto_participation_issue_url(issue.slug, options)
    end
  end
end
