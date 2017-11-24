module GobiertoCalendars
  class IbmNotesCalendarConfiguration < CalendarConfiguration

    def ibm_notes_usr
      data['ibm_notes_usr']
    end

    def ibm_notes_usr=(ibm_notes_usr)
      data['ibm_notes_usr'] = ibm_notes_usr
    end

    def ibm_notes_pwd
      data['ibm_notes_pwd']
    end

    def ibm_notes_pwd=(ibm_notes_pwd)
      data['ibm_notes_pwd'] = ibm_notes_pwd
    end

    def ibm_notes_url
      data['ibm_notes_url']
    end

    def ibm_notes_url=(ibm_notes_url)
      data['ibm_notes_url'] = ibm_notes_url
    end

  end
end
