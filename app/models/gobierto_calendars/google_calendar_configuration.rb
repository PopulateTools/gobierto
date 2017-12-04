module GobiertoCalendars
  class GoogleCalendarConfiguration < CalendarConfiguration

    def google_calendar_credentials
      data['google_calendar_credentials']
    end

    def google_calendar_credentials=(value)
      data['google_calendar_credentials'] = value
    end

    def google_calendar_id
      data['google_calendar_id']
    end

    def google_calendar_id=(value)
      data['google_calendar_id'] = value
    end

    def calendars=(value)
      data['calendars'] = value
    end

    def calendars
      data['calendars']
    end

  end
end
