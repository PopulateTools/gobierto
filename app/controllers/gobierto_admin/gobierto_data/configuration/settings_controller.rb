# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    module Configuration
      class SettingsController < GobiertoAdmin::GobiertoData::BaseController
        def edit
          @settings_form = SettingsForm.new(site_id: current_site.id)
        end

        def update
          @settings_form = SettingsForm.new(settings_params.merge(site_id: current_site.id))

          if @settings_form.save
            redirect_to edit_admin_data_configuration_settings_path, notice: t(".success")
          else
            render :edit
          end
        end

        private

        def settings_params
          params.require(:gobierto_data_settings).permit(:db_config, :frontend_enabled)
        end
      end
    end
  end
end
