# frozen_string_literal: true

module GobiertoDashboards
  module Api
    module V1
      class BaseController < ApiBaseController
        include ActionController::MimeResponds

        before_action { module_enabled!(current_site, "GobiertoDashboards", false) }
      end
    end
  end
end
