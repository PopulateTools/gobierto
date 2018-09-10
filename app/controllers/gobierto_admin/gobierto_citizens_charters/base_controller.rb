# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, current_admin_module) }
      before_action { module_allowed!(current_admin, current_admin_module) }
    end
  end
end
