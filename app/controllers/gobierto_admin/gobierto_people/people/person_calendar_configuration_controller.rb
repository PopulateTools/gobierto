module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonCalendarConfigurationController < BaseController
        before_action { module_enabled!(current_site, 'GobiertoPeople') }

        def edit
          @calendar_configuration_form = PersonCalendarConfigurationForm.new(person_id: @person.id)
          @google_calendar_configuration = find_google_calendar_configuration

          render 'gobierto_admin/gobierto_people/people/person_events/person_calendar_configuration/edit'
        end

        def update
          @calendar_configuration_form = PersonCalendarConfigurationForm.new(
            calendar_configuration_params.merge(person_id: @person.id)
          )

          @calendar_configuration_form.save
          redirect_to(
            edit_admin_people_person_calendar_configuration_path,
            notice: t('.success')
          )
        end

        private

        def calendar_configuration_params
          params.require(:calendar_configuration).permit(:ibm_notes_url, :clear_google_calendar_configuration)
        end

        def find_google_calendar_configuration
          ::GobiertoPeople::PersonGoogleCalendarConfiguration.find_by person_id: @person.id
        end

      end
    end
  end
end
