module GobiertoCalendars
  class GoogleCalendarCalendarsForm
    include ActiveModel::Model

    attr_accessor(
      :person_id,
      :calendars
    )

    delegate :persisted?, to: :google_calendar_configuration

    validates :person, presence: true
    validates :google_calendar_configuration, presence: true

    def save
      save_google_calendar_configuration if valid?
    end

    def person
      @person ||= person_class.find_by(id: person_id)
    end

    def calendars
      @calendars ||= @google_calendar_configuration.calendars
    end

    def google_calendar_configuration
      @google_calendar_configuration ||= google_calendar_configuration_class.find_by(collection: person.calendar)
    end

    private

    def person_class
      ::GobiertoPeople::Person
    end

    def google_calendar_configuration_class
      ::GobiertoCalendars::GoogleCalendarConfiguration
    end

    def save_google_calendar_configuration
      @google_calendar_configuration = google_calendar_configuration.tap do |google_calendar_configuration_attributes|
        google_calendar_configuration_attributes.calendars = calendars.select { |c| !c.blank? }
      end

      if @google_calendar_configuration.valid?
        @google_calendar_configuration.save

        @google_calendar_configuration
      else
        promote_errors(@google_calendar_configuration.errors)

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
