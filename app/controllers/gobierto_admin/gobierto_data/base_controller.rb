# frozen_string_literal: true

require "#{Rails.root}/app/models/gobierto_data"

module GobiertoAdmin
  module GobiertoData
    class BaseController < GobiertoAdmin::BaseController
      helper_method :frontend_enabled?

      before_action { module_enabled!(current_site, "GobiertoData") }
      before_action { module_allowed!(current_admin, "GobiertoData") }

      protected

      def frontend_enabled?
        @frontend_enabled ||= current_site.configuration.modules_with_frontend_enabled.include?("GobiertoData")
      end
    end
  end
end
