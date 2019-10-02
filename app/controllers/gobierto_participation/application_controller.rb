module GobiertoParticipation
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    helper_method :current_process

    layout 'gobierto_participation/layouts/application'

    before_action { module_enabled!(current_site, 'GobiertoParticipation') }

    def find_issues
      CollectionDecorator.new(current_site.issues, decorator: ProcessTermDecorator)
    end

    def find_issue
      ProcessTermDecorator.new(current_site.issues.find_by_slug!(params[:issue_id]))
    end

    def find_scopes
      CollectionDecorator.new(current_site.scopes, decorator: ProcessTermDecorator)
    end

    def find_scope
      ProcessTermDecorator.new(current_site.scopes.find_by_slug!(params[:scope_id]))
    end

    def current_user_issue_id
      return unless user_signed_in? && current_site.present?

      ::GobiertoCommon::CustomFieldRecord.find_by(custom_field_id: current_site.gobierto_participation_settings&.users_issues_field_id, item: current_user)&.raw_value
    end

    protected

    def current_process
      nil
    end
  end
end
