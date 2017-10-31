# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class WelcomeController < BaseController

      before_action { module_enabled!(current_site,  'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      def index
        active_polls = ::GobiertoParticipation::Poll.by_site(current_site).open
        @next_elements = (active_polls + current_site.contribution_containers.active.open).sort_by(&:days_left)
        @processes = current_site.processes.active.sort_by(&:last_activity_at).reverse
        @activities = find_participation_activities
      end

      def find_participation_activities
        ActivityCollectionDecorator.new(Activity.no_admin.in_site(current_site).in_participation.sorted.includes(:subject, :author, :recipient).page(params[:page]))
      end
    end
  end
end
