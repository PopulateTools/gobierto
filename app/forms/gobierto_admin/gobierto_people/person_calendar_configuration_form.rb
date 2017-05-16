module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationForm
      include ActiveModel::Model

      attr_accessor(
        :person_id,
        :ibm_notes_url,
        :clear_google_calendar_configuration
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
        @ibm_notes_url ||= person_calendar_configuration.endpoint
      end

      private

      def site
        @site ||= ::GobiertoPeople::Person.find_by(id: person_id).site
      end

      def person_calendar_configuration_class
        @person_calendar_configuration_class ||= site.calendar_integration.person_calendar_configuration_class
      end

      def save_calendar_configuration
        @person_calendar_configuration = person_calendar_configuration.tap do |calendar_configuration_attributes|
          calendar_configuration_attributes.person_id = person_id

          if clear_google_calendar_configuration
            calendar_configuration_attributes.google_calendar_credentials = nil
            calendar_configuration_attributes.google_calendar_id = nil
          end

          if calendar_configuration_attributes.respond_to?(:endpoint)
            calendar_configuration_attributes.endpoint = ibm_notes_url
          end
        end

        if @person_calendar_configuration.valid?
          @person_calendar_configuration.save

          @person_calendar_configuration
        else
          promote_errors(@person_calendar_configuration.errors)

          false
        end
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
