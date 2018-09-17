# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class BaseController < GobiertoAdmin::BaseController
      helper_method :charters_enabled?, :services_enabled?, :preview_url

      before_action { module_enabled!(current_site, current_admin_module) }
      before_action { module_allowed!(current_admin, current_admin_module) }

      protected

      def services_enabled?
        !current_site.gobierto_citizens_charters_settings&.disable_services
      end

      def charters_enabled?
        !current_site.gobierto_citizens_charters_settings&.disable_charters
      end

      def preview_url(service, options = {})
        options[:preview_token] = current_admin.preview_token unless service.active?
        admin_citizens_charters_services_url(options)
      end
    end
  end
end
