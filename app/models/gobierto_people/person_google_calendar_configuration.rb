module GobiertoPeople
  class PersonGoogleCalendarConfiguration < PersonCalendarConfiguration
    def google_calendar_credentials=(value)
      data['google_calendar_credentials'] = value
    end

    def google_calendar_credentials
      data['google_calendar_credentials']
    end

    def google_calendar_id
      data['google_calendar_id']
    end

    def google_calendar_id=(value)
      data['google_calendar_id'] = value
    end
  end
end
