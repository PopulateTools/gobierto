module GobiertoPeople
  class PersonMicrosoftExchangeCalendarConfiguration < PersonCalendarConfiguration

    def microsoft_exchange_usr
      data['microsoft_exchange_usr']
    end

    def microsoft_exchange_usr=(microsoft_exchange_usr)
      data['microsoft_exchange_usr'] = microsoft_exchange_usr
    end

    def microsoft_exchange_pwd
      data['microsoft_exchange_pwd']
    end

    def microsoft_exchange_pwd=(microsoft_exchange_pwd)
      data['microsoft_exchange_pwd'] = microsoft_exchange_pwd
    end

    def microsoft_exchange_url
      data['microsoft_exchange_url']
    end

    def microsoft_exchange_url=(microsoft_exchange_url)
      data['microsoft_exchange_url'] = microsoft_exchange_url
    end

  end
end
