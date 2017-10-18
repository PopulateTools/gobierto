module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonCalendarConfigurationController < BaseController
        before_action { module_enabled!(current_site, 'GobiertoPeople') }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        def edit
          @calendar_configuration_form = PersonCalendarConfigurationForm.new(person_id: @person.id)
          @google_calendar_configuration = find_google_calendar_configuration
          @calendars = load_calendars

          render 'gobierto_admin/gobierto_people/people/person_events/person_calendar_configuration/edit'
        end

        def update
          @calendar_configuration_form = PersonCalendarConfigurationForm.new(
            calendar_configuration_params.merge(person_id: @person.id)
          )

          if @calendar_configuration_form.save
            redirect_to(
              edit_admin_people_person_calendar_configuration_path,
              notice: t('.success')
            )
          else
            render 'gobierto_admin/gobierto_people/people/person_events/person_calendar_configuration/edit'
          end
        end

        private

        def calendar_configuration_params
          params.require(:calendar_configuration).permit(
            :ibm_notes_url,
            :microsoft_exchange_usr,
            :microsoft_exchange_pwd,
            :microsoft_exchange_url,
            :clear_google_calendar_configuration,
            :clear_microsoft_exchange_configuration,
            calendars: []
          )
        end

        def find_google_calendar_configuration
          if configuration = ::GobiertoPeople::PersonGoogleCalendarConfiguration.find_by(person_id: @person.id)
            if configuration.google_calendar_credentials.blank?
              nil
            else
              configuration
            end
          end
        end

        def load_calendars
          if calendar_service
            calendar_service.calendars
          else
            []
          end
        end

        def calendar_service
          @calendar_service ||= if @google_calendar_configuration
                                  ::GobiertoPeople::GoogleCalendar::CalendarIntegration.new(@person)
                                end
        end
      end
    end
  end
end
