module GobiertoParticipation
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    helper_method :current_process

    layout 'gobierto_participation/layouts/application'

    before_action { gobierto_module_enabled!(current_site, 'GobiertoParticipation') }

    protected

    def current_process
      nil
    end
  end
end
