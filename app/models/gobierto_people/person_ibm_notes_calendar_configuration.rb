module GobiertoPeople
  class PersonIbmNotesCalendarConfiguration < PersonCalendarConfiguration

    def endpoint
      data['endpoint']
    end

    def endpoint=(endpoint)
      data['endpoint'] = endpoint
    end

  end
end
