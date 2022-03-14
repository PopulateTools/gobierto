module GobiertoCms
  class ApplicationController < ::ApplicationController
    include User::SessionHelper
    include ::PreviewTokenHelper

    layout "gobierto_cms/layouts/application"

    helper_method :cache_service

    private

    def cache_service
      @cache_service ||= GobiertoCommon::CacheService.new(current_site, "GobiertoCms")
    end
  end
end
