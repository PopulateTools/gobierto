module GobiertoAdmin
  module GobiertoParticipation
    class WelcomeController < BaseController

      before_action { module_enabled!(current_site,  'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      def index
      end

    end
  end
end
