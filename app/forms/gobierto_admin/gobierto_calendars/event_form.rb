module GobiertoAdmin
  module GobiertoCalendars
    class EventForm
      include ActiveModel::Model
      prepend ::GobiertoCommon::Trackable

      attr_accessor(
        :id,
        :admin_id,
        :collection_id,
        :site_id,
        :title_translations,
        :description_translations,
        :starts_at,
        :ends_at,
        :attachment_ids,
        :state,
        :locations,
        :attendees,
        :slug
      )

      delegate :persisted?, to: :event

      validates :title_translations, presence: true
      validates :starts_at, :ends_at, :site, :collection, presence: true

      trackable_on :event

      notify_changed :state

      def save
        save_event if valid?
      end

      def admin_id
        @admin_id ||= event.admin_id
      end

      def site_id
        @site_id ||= collection.try(:site_id)
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def event
        @event ||= event_class.find_by(id: id).presence || build_event
      end

      def collection
        @collection ||= collection_class.find_by(id: collection_id)
      end

      def person
        @person ||= if collection.container.is_a?(person_class)
                      collection.container
                    end
      end

      def locations
        @locations ||= event.locations.presence || [build_event_location]
      end

      def locations_attributes=(attributes)
        @locations ||= []

        attributes.each do |_, location_attributes|
          next if location_attributes["_destroy"] == "1"

          location = event_location_class.new(
            name: location_attributes[:name],
            address: location_attributes[:address],
            lat: location_attributes[:lat],
            lng: location_attributes[:lng]
          )

          @locations.push(location) if location.valid?
        end
      end

      def attendees
        @attendees ||= event.attendees.presence || [build_event_attendee]

        if person.present?
          if event.attendees.any?
            unless organizer = event.attendees.find_by(person_id: person.id)
              organizer = event_attendee_class.new(person_id: person.id)
            end
          else
            organizer = event_attendee_class.new(person_id: person.id)
          end
          @attendees.push(organizer) unless @attendees.include?(organizer)
        end

        @attendees
      end

      def attendees_attributes=(attributes)
        @attendees ||= []

        attributes.each do |_, attendee_attributes|
          next if attendee_attributes["_destroy"] == "1"

          attendee = event_attendee_class.new(
            person_id: attendee_attributes[:person_id],
            name: attendee_attributes[:name],
            charge: attendee_attributes[:charge]
          )

          @attendees.push(attendee) if attendee.valid?
        end
      end

      def starts_at
        @starts_at ||= (1.hour.from_now.beginning_of_hour + 1.day).localtime

        if @starts_at.respond_to?(:strftime)
          return @starts_at.strftime("%Y-%m-%d %H:%M")
        end

        @starts_at
      end

      def ends_at
        if @ends_at.respond_to?(:strftime)
          return @ends_at.strftime("%Y-%m-%d %H:%M")
        end

        @ends_at
      end

      def state
        @state ||= "pending"
      end

      def notify?
        event.active?
      end

      private

      def build_event
        event_class.new
      end

      def build_event_location
        event.locations.build
      end

      def build_event_attendee
        event.attendees.build
      end

      def event_class
        ::GobiertoCalendars::Event
      end

      def event_location_class
        ::GobiertoCalendars::EventLocation
      end

      def event_attendee_class
        ::GobiertoCalendars::EventAttendee
      end

      def person_class
        ::GobiertoPeople::Person
      end

      def collection_class
        ::GobiertoCommon::Collection
      end

      def save_event
        @event = event.tap do |event_attributes|
          event_attributes.collection = collection
          event_attributes.site_id = site_id
          event_attributes.state = state
          event_attributes.title_translations = title_translations
          event_attributes.description_translations = description_translations
          event_attributes.starts_at = starts_at
          event_attributes.ends_at = ends_at
          event_attributes.admin_id = admin_id
          event_attributes.locations = locations
          event_attributes.attendees = attendees
          event_attributes.slug = slug

          if event.new_record? && attachment_ids.present?
            if attachment_ids.is_a?(String)
              event_attributes.attachment_ids = attachment_ids.split(",")
            else
              event_attributes.attachment_ids = attachment_ids
            end
          end
        end

        if @event.valid?
          run_callbacks(:save) do
            @event.save
          end

          @event
        else
          promote_errors(@event.errors)

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
