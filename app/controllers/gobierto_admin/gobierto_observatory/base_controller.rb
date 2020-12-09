# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoObservatory
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoObservatory") }
      before_action { module_allowed!(current_admin, "GobiertoObservatory") }
    end
  end
end
