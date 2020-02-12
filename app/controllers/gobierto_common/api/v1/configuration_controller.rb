# frozen_string_literal: true

module GobiertoCommon
  module Api
    module V1
      class ConfigurationController < ApiBaseController
        before_action { module_enabled!(current_site, module_name, false) }

        # GET /api/v1/:module_name/configuration
        def show
          settings = current_site.module_settings.find_by(module_name: module_name)
          return unless settings.present?

          render json: settings.public_api_settings
        end

        private

        def module_name
          @module_name ||= begin
                             module_param = params[:module_name].underscore
                             module_param = /\Agobierto_/.match?(module_param) ? module_param : "gobierto_#{module_param}"
                             module_param.camelize
                           end
        end
      end
    end
  end
end
