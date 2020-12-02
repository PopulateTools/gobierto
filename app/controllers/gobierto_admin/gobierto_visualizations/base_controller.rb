# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoVisualizations
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoVisualizations") }
      before_action { module_allowed!(current_admin, "GobiertoVisualizations") }
    end
  end
end
