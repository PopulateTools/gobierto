module GobiertoPeople
  module People
    module GoogleCalendar
      class CalendarsController < ::GobiertoPeople::People::BaseController
        before_action :check_person_session

        layout "gobierto_people/layouts/application"

        def edit
          @calendars = calendar_service.calendars
          @calendars_form = GobiertoCalendars::GoogleCalendarCalendarsForm.new(person_id: @person.id)
        end

        def update
          @calendars_form = GobiertoCalendars::GoogleCalendarCalendarsForm.new(calendars_params.merge(person_id: @person.id))
          @calendars_form.save
          redirect_to edit_gobierto_people_person_google_calendar_calendars_path(@person.slug), notice: t('.success')
        end

        private

        def calendar_service
          @calendar_service ||= GobiertoPeople::GoogleCalendar::CalendarIntegration.new(@person)
        end

        def check_person_session
          if session[:google_calendar_person_id] != @person.id
            render_404 and return false
          end
        end

        def calendars_params
          params.require(:calendars_form).permit(
            calendars: []
          )
        end
      end
    end
  end
end
