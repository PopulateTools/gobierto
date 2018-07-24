# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class BaseController < ::GobiertoAdmin::BaseController

      include ::GobiertoCommon::ModuleHelper

      before_action { gobierto_module_enabled!(current_site, "GobiertoCms") }
      before_action { module_allowed!(current_admin, "GobiertoCms") }

    end
  end
end
