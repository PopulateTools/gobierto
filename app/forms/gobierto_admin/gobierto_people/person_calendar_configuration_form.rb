module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationForm

      include ActiveModel::Model

      ENCRYPTED_SETTING_PLACEHOLDER = 'encrypted_setting_placeholder'

      attr_accessor(
        :person_id,
        :ibm_notes_url,
        :microsoft_exchange_usr,
        :microsoft_exchange_pwd,
        :microsoft_exchange_url,
        :clear_microsoft_exchange_configuration,
        :clear_google_calendar_configuration,
        :calendars
      )

      validates(
        :microsoft_exchange_usr,
        :microsoft_exchange_pwd,
        :microsoft_exchange_url,
        presence: true, if: -> { any_microsoft_exchange_settings? && !clear_microsoft_exchange_configuration? }
      )

      def save
        save_calendar_configuration if valid?
      end

      def person_calendar_configuration
        @person_calendar_configuration ||= person_calendar_configuration_class.find_by(person_id: person_id) || person_calendar_configuration_class.new
      end

      def person_id
        @person_id ||= person_calendar_configuration.person_id
      end

      def ibm_notes_url
        @ibm_notes_url ||= if person_calendar_configuration.respond_to?(:endpoint)
                             person_calendar_configuration.endpoint
                           end
      end

      def microsoft_exchange_usr
        @microsoft_exchange_usr ||= if person_calendar_configuration.respond_to?(:microsoft_exchange_usr)
                                      person_calendar_configuration.microsoft_exchange_usr
                                    end
      end

      def microsoft_exchange_pwd
        @microsoft_exchange_pwd ||= if person_calendar_configuration.respond_to?(:microsoft_exchange_pwd)
                                      person_calendar_configuration.microsoft_exchange_pwd
                                    end
      end

      def microsoft_exchange_url
        @microsoft_exchange_url ||= if person_calendar_configuration.respond_to?(:microsoft_exchange_url)
                                      person_calendar_configuration.microsoft_exchange_url
                                    end
      end

      def dummy_microsoft_exchange_pwd
        if microsoft_exchange_pwd.present? && microsoft_exchange_pwd != ENCRYPTED_SETTING_PLACEHOLDER
          ENCRYPTED_SETTING_PLACEHOLDER
        else
          microsoft_exchange_pwd
        end
      end

      def calendars
        @calendars ||= if person_calendar_configuration.respond_to?(:calendars)
                         person_calendar_configuration.calendars
                       end
      end

      private

      def person_google_calendar_configuration_class
        ::GobiertoPeople::PersonGoogleCalendarConfiguration
      end

      def person_ibm_notes_configuration_class
        ::GobiertoPeople::PersonIbmNotesCalendarConfiguration
      end

      def person_microsoft_exchange_configuration_class
        ::GobiertoPeople::PersonMicrosoftExchangeCalendarConfiguration
      end

      def person
        @person ||= ::GobiertoPeople::Person.find_by(id: person_id)
      end

      def site
        @site ||= person.site
      end

      def person_calendar_configuration_class
        @person_calendar_configuration_class ||= site.calendar_integration.person_calendar_configuration_class
      end

      def clear_google_calendar_configuration?
        person_google_calendar_configuration_class == person_calendar_configuration.class && clear_google_calendar_configuration == "1"
      end

      def clear_ibm_notes_configuration?
        person_ibm_notes_configuration_class == person_calendar_configuration.class && ibm_notes_url.blank?
      end

      def clear_microsoft_exchange_configuration?
        person_microsoft_exchange_configuration_class == person_calendar_configuration.class &&
        (clear_microsoft_exchange_configuration == "1" || !any_microsoft_exchange_settings?)
      end

      def save_calendar_configuration
        @person_calendar_configuration = person_calendar_configuration.tap do |calendar_configuration_attributes|
          calendar_configuration_attributes.person_id = person_id

          if person_calendar_configuration.respond_to?(:calendars)
            calendar_configuration_attributes.calendars = calendars.select { |c| !c.blank? }
          end

          if calendar_configuration_attributes.respond_to?(:endpoint)
            calendar_configuration_attributes.endpoint = ibm_notes_url
          end

          if calendar_configuration_attributes.respond_to?(:microsoft_exchange_usr)
            calendar_configuration_attributes.microsoft_exchange_usr = microsoft_exchange_usr
          end

          if calendar_configuration_attributes.respond_to?(:microsoft_exchange_pwd)
            calendar_configuration_attributes.microsoft_exchange_pwd = encrypted_microsoft_exchange_pwd
          end

          if calendar_configuration_attributes.respond_to?(:microsoft_exchange_url)
            calendar_configuration_attributes.microsoft_exchange_url = microsoft_exchange_url.strip
          end
        end

        if @person_calendar_configuration.valid?
          if clear_google_calendar_configuration? || clear_ibm_notes_configuration? || clear_microsoft_exchange_configuration?
            ::GobiertoPeople::ClearImportedPersonEventsJob.perform_later(person)

            @person_calendar_configuration.destroy

            true
          else
            @person_calendar_configuration.save

            @person_calendar_configuration
          end
        else
          promote_errors(@person_calendar_configuration.errors)

          false
        end
      end

      private

      def encrypted_microsoft_exchange_pwd
        if microsoft_exchange_pwd.present? && microsoft_exchange_pwd != ENCRYPTED_SETTING_PLACEHOLDER
          ::SecretAttribute.encrypt(microsoft_exchange_pwd)
        elsif microsoft_exchange_pwd == ENCRYPTED_SETTING_PLACEHOLDER
          person_calendar_configuration.microsoft_exchange_pwd
        else
          nil
        end
      end

      def any_microsoft_exchange_settings?
        microsoft_exchange_usr.present? || microsoft_exchange_pwd.present? || microsoft_exchange_url.present?
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end

    end
  end
end
