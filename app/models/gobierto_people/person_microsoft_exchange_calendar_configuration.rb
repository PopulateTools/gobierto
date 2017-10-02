module GobiertoPeople
  class PersonMicrosoftExchangeCalendarConfiguration < PersonCalendarConfiguration

    def microsoft_exchange_email
      data['microsoft_exchange_email']
    end

    def microsoft_exchange_email=(microsoft_exchange_email)
      data['microsoft_exchange_email'] = microsoft_exchange_email
    end

  end
end
