# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Api
      class BaseController < GobiertoAdmin::Api::BaseController
        helper_method :charters_enabled?, :services_enabled?

        before_action { module_enabled!(current_site, current_admin_module) }
        before_action { module_allowed!(current_admin, current_admin_module) }

        protected

        def services_enabled?
          !current_site.gobierto_citizens_charters_settings&.disable_services
        end

        def charters_enabled?
          !current_site.gobierto_citizens_charters_settings&.disable_charters
        end
      end
    end
  end
end
