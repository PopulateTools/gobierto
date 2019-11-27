# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoData") }
      before_action { module_allowed!(current_admin, "GobiertoData") }
    end
  end
end
