module GobiertoAdmin
  module GobiertoPeople
    module Configuration
      class SettingsController < BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }

        def index
          @settings = current_site.gobierto_people_settings.all
        end

        def update
          @setting = find_setting
          @setting_form = SettingForm.new(
            setting_params.merge(id: params[:id])
          )

          @setting_form.save
          redirect_to(
            admin_people_configuration_settings_path,
            notice: t(".success")
          )
        end

        private

        def find_setting
          current_site.gobierto_people_settings.find(params[:id])
        end

        def setting_params
          params.require(:gobierto_people_setting).permit(:value)
        end
      end
    end
  end
end
