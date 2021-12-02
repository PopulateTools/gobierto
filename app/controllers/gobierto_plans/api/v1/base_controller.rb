# frozen_string_literal: true

module GobiertoPlans
  module Api
    module V1
      class BaseController < ApiBaseController
        include ActionController::MimeResponds
        include ::PreviewTokenHelper

        before_action { module_enabled!(current_site, "GobiertoPlans", false) }

        private

        def cache_service
          @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoInvestments")
        end
      end
    end
  end
end
