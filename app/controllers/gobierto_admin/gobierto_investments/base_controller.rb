# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoInvestments
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoInvestments") }
      before_action { module_allowed!(current_admin, "GobiertoInvestments") }
    end
  end
end
