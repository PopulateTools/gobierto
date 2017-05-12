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
      :locations,
      :attendees
    )

    delegate :persisted?, to: :person_event

    validates :external_id, presence: true
    validates :title, presence: true
    validates :starts_at, :ends_at, presence: true
    validates :person, presence: true

    trackable_on :person_event

    notify_changed :state

    def save
      save_person_event if valid?
    end

    def site_id
      @site_id ||= person.site_id
    end

    def admin
      @admin ||= Admin.find_by(id: admin_id)
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def person_event
      @person_event ||= person.events.find_by(external_id: external_id).presence || build_person_event
    end

    def person
      @person ||= person_class.find_by(id: person_id)
    end

    def locations
      @locations ||= person_event.locations.presence || [build_person_event_location]
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
    end

    def attendees=(attendees_attributes)
      @attendees = []

      attendees_attributes.each do |attendee_attributes|
        name  = attendee_attributes[:name]
        email = attendee_attributes[:email]

        attendee_person = site.people.find_by(email: email)

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
      person_event.active?
    end

    private

    def build_person_event
      person_event_class.new
    end

    def build_person_event_location
      person_event.locations.build
    end

    def build_person_event_attendee
      person_event.attendees.build
    end

    def person_event_class
      ::GobiertoPeople::PersonEvent
    end

    def person_event_location_class
      ::GobiertoPeople::PersonEventLocation
    end

    def person_event_attendee_class
      ::GobiertoPeople::PersonEventAttendee
    end

    def person_class
      ::GobiertoPeople::Person
    end

    def save_person_event
      @person_event = person_event.tap do |person_event_attributes|
        person_event_attributes.external_id = external_id
        person_event_attributes.person_id = person_id
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
          run_callbacks(:save) do
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
