module GobiertoParticipation
  class ApplicationController < ::ApplicationController
    include User::SessionHelper

    layout 'gobierto_participation/layouts/application'

    before_action { module_enabled!(current_site, 'GobiertoParticipation') }
  end
end
