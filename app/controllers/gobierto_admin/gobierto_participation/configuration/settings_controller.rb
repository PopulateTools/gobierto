# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Configuration
      class SettingsController < BaseController
        def edit
          @settings_form = SettingsForm.new(site_id: current_site.id)
        end

        def update
          @settings_form = SettingsForm.new(settings_params.merge(site_id: current_site.id))

          if @settings_form.save
            redirect_to edit_admin_participation_configuration_settings_path, notice: t(".success")
          else
            redirect_to edit_admin_participation_configuration_settings_path, notice: t(".error")
          end
        end

        private

        def settings_params
          params.require(:gobierto_participation_settings).permit(:issues_vocabulary_id, :scopes_vocabulary_id)
        end
      end
    end
  end
end
