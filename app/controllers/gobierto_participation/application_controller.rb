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

    protected

    def current_process
      nil
    end
  end
end
