# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class WelcomeController < GobiertoAdmin::BaseController
      before_action { gobierto_module_enabled!(current_site, "GobiertoParticipation") }
      before_action { module_allowed!(current_admin, "GobiertoParticipation") }

      def index
        @next_elements = find_next_elements_to_close
        @processes = current_site.processes.sort_by(&:last_activity_at).reverse
        @archived_processes = current_site.processes.only_archived
        @activities = find_participation_activities
      end

      private

      def find_participation_activities
        ActivityCollectionDecorator.new(Activity.no_admin.in_site(current_site).in_participation(current_site).sorted.includes(:subject, :author, :recipient).limit(40))
      end

      def find_next_elements_to_close
        active_polls = ::GobiertoParticipation::Poll.by_site(current_site).open
        contribution_containers = ::GobiertoParticipation::ContributionContainer.by_site(current_site).active.open

        (active_polls + contribution_containers).sort_by(&:days_left)
      end
    end
  end
end
