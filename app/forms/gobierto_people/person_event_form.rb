module GobiertoPeople
  class PersonEventForm
    include ActiveModel::Model
    prepend ::GobiertoCommon::Trackable

    attr_accessor(
      :external_id,
      :site_id,
      :person_id,
      :title,
      :description,
      :starts_at,
      :ends_at,
      :state,
      :notify,
      :locations,
      :attendees,
      :recurring
    )

    delegate :persisted?, to: :person_event

    validates :external_id, :title, :starts_at, :ends_at, :site, :collection, presence: true
    validate :recurring_event_in_window

    trackable_on :person_event

    notify_changed :state

    def save
      save_person_event if valid?
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def recurring?
      @recurring ||= false
    end

    def person_event
      @person_event ||= event_class.by_site(site).
        find_by(external_id: external_id).presence || build_person_event
    end

    def person
      @person ||= person_class.find_by(id: person_id)
    end

    def collection
      @collection ||= person.try(:events_collection)
    end

    def locations
      @locations ||= []
    end

    def locations_attributes=(attributes)
      @locations = []

      attributes.each do |_, location_attributes|
        next if location_attributes["_destroy"] == "1"

        location = person_event.locations.detect{ |l| l.name == location_attributes[:name] } ||
          person_event_location_class.new(name: location_attributes[:name])

        @locations.push(location) if location.valid?
      end
    end

    def attendees
      @attendees ||= person_event.attendees.presence || []

      return @attendees if person.nil?

      if person_event.attendees.any?
        unless organizer = person_event.attendees.find_by(person_id: person_id)
          organizer = person_event_attendee_class.new(person_id: person_id)
        end
      else
        organizer = person_event_attendee_class.new(person_id: person_id)
      end
      @attendees.push(organizer) unless @attendees.any?{ |a| a.person_id == organizer.person_id }

      @attendees
    end

    def attendees=(attendees_attributes)
      @attendees = []

      attendees_attributes.each do |attendee_attributes|
        name  = attendee_attributes[:name]
        email = attendee_attributes[:email]

        attendee_person = attendee_attributes[:person] || site.people.find_by(email: email)

        existing_attendee = person_event.attendees.detect do |a|
          (attendee_person.present? && a.person == attendee_person) || a.name == name
        end

        attendee = if existing_attendee
                     existing_attendee
                   elsif attendee_person.present?
                     person_event_attendee_class.new(person: attendee_person)
                   else
                     person_event_attendee_class.new(name: name)
                   end

        @attendees.push(attendee) if attendee.valid?
      end
    end

    def state
      @state ||= person_event.state || "published"
    end

    def notify?
      notify && person_event.active? && person.present?
    end

    private

    def build_person_event
      event_class.new site_id: site_id
    end

    def event_class
      ::GobiertoCalendars::Event
    end

    def build_person_event_location
      person_event.locations.build
    end

    def build_person_event_attendee
      person_event.attendees.build
    end

    def person_event_location_class
      ::GobiertoCalendars::EventLocation
    end

    def person_event_attendee_class
      ::GobiertoCalendars::EventAttendee
    end

    def person_class
      ::GobiertoPeople::Person
    end

    def recurring_event_in_window
      if recurring?
        errors.add(:starts_at) if starts_at > 3.months.from_now || starts_at < 1.year.ago
      end
    end

    def save_person_event
      @person_event = person_event.tap do |person_event_attributes|
        person_event_attributes.site_id = site_id
        person_event_attributes.external_id = external_id
        person_event_attributes.collection = collection
        person_event_attributes.state = state
        person_event_attributes.title = title
        person_event_attributes.description = description
        person_event_attributes.starts_at = starts_at
        person_event_attributes.ends_at = ends_at
        person_event_attributes.locations = locations
        person_event_attributes.attendees = attendees
      end

      if @person_event.valid?
        if @person_event.changes.any?
          if notify?
            run_callbacks(:save) do
              @person_event.save
            end
          else
            @person_event.save
          end
        end

        @person_event
      else
        promote_errors(@person_event.errors)

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
