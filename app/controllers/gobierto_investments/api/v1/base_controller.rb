# frozen_string_literal: true

module GobiertoInvestments
  module Api
    module V1
      class BaseController < ApiBaseController

        before_action { module_enabled!(current_site, "GobiertoInvestments", false) }

        private

        def cache_service
          @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoInvestments")
        end
      end
    end
  end
end
