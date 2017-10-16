module GobiertoAdmin
  module GobiertoPeople
    module Configuration
      class SettingsController < BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        def edit
          @settings_form = SettingsForm.new(site_id: current_site.id)
          @available_submodules = find_available_submodules
          @calendar_integrations_options = find_calendar_integrations
        end

        def update
          @settings_form = SettingsForm.new(
            settings_params.merge(site_id: current_site.id)
          )

          if @settings_form.save
            redirect_to edit_admin_people_configuration_settings_path, notice: t(".success")
          else
            redirect_to edit_admin_people_configuration_settings_path, alert: t(".error")
          end
        end

        private

        def settings_params
          params.require(:gobierto_people_settings).permit(
            :home_text_es,
            :home_text_ca,
            :home_text_en,
            :calendar_integration,
            :ibm_notes_usr,
            :ibm_notes_pwd,
            submodules_enabled: []
          )
        end

        def find_available_submodules
          ::GobiertoPeople.module_submodules.map do |submodule|
            [submodule, submodule]
          end
        end

        def find_calendar_integrations
          ::GobiertoPeople.remote_calendar_integrations.map do |integration_name|
            [
              I18n.t("gobierto_admin.gobierto_people.configuration.settings.edit.#{integration_name}"),
              integration_name
            ]
          end
        end
      end
    end
  end
end
