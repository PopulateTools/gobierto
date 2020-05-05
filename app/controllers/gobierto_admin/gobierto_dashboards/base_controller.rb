# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoDashboards
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoDashboards") }
      before_action { module_allowed!(current_admin, "GobiertoDashboards") }
    end
  end
end
