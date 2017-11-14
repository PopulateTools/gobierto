# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class WelcomeController < GobiertoAdmin::BaseController

      before_action { module_enabled!(current_site,  'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      def index
        @next_elements = find_next_elements_to_close
        @processes = current_site.processes.sort_by(&:last_activity_at).reverse
        @activities = find_participation_activities
      end

      private

      def find_participation_activities
        ActivityCollectionDecorator.new(Activity.no_admin.in_site(current_site).in_participation.sorted.includes(:subject, :author, :recipient).limit(40))
      end

      def find_next_elements_to_close
        active_polls = ::GobiertoParticipation::Poll.by_site(current_site).open
        (active_polls + current_site.contribution_containers.active.open).sort_by(&:days_left)
      end
    end
  end
end
