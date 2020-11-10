# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoVisualizations
    module Configuration
      class SettingsController < GobiertoAdmin::GobiertoVisualizations::BaseController
        def edit
          @settings_form = SettingsForm.new(site_id: current_site.id)
        end

        def update
          @settings_form = SettingsForm.new(settings_params.merge(site_id: current_site.id))

          if @settings_form.save
            redirect_to edit_admin_visualizations_configuration_settings_path, notice: t(".success")
          else
            redirect_to edit_admin_visualizations_configuration_settings_path, alert: t(".error", validation_errors: @settings_form.errors.full_messages.to_sentence)
          end
        end

        private

        def settings_params
          params.require(:gobierto_visualizations_settings).permit(:visualizations_config)
        end
      end
    end
  end
end
