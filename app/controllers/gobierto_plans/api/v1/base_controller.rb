# frozen_string_literal: true

module GobiertoPlans
  module Api
    module V1
      class BaseController < ApiBaseController
        include ActionController::MimeResponds
        include ::User::ApiAuthenticationHelper
        include ::PreviewTokenHelper

        before_action { module_enabled!(current_site, "GobiertoPlans", false) }

      end
    end
  end
end
