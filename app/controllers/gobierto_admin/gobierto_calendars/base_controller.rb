# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCalendars
    class BaseController < ::GobiertoAdmin::BaseController

      before_action { gobierto_module_enabled!(current_site, "GobiertoCalendars") }
      before_action { module_allowed!(current_admin, "GobiertoCalendars") }

    end
  end
end
