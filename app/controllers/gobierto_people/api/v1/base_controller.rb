# frozen_string_literal: true

module GobiertoPeople
  module Api
    module V1
      class BaseController < ApiBaseController

        before_action { gobierto_module_enabled!(current_site, "GobiertoPeople", false) }

      end
    end
  end
end
