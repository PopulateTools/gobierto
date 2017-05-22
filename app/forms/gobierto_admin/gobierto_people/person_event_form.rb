module GobiertoAdmin
  module GobiertoPeople
    class PersonEventForm
      include ActiveModel::Model
      prepend ::GobiertoCommon::Trackable

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :person_id,
        :title_translations,
        :description_translations,
        :starts_at,
        :ends_at,
        :attachment_file,
        :attachment_url,
        :state,
        :locations,
        :attendees
      )

      delegate :persisted?, to: :person_event

      validates :title_translations, presence: true
      validates :starts_at, :ends_at, presence: true
      validates :person, presence: true
      validates :site, presence: true

      trackable_on :person_event

      notify_changed :state

      def save
        save_person_event if valid?
      end

      def admin_id
        @admin_id ||= person_event.admin_id
      end

      def site_id
        @site_id ||= person.site_id
      end

      def admin
        @admin ||= Admin.find_by(id: admin_id)
      end

      def site
        @site ||= person.try(:site)
      end

      def person_event
        @person_event ||= person_event_class.find_by(id: id).presence || build_person_event
      end

      def person_id
        @person_id ||= person_event.person_id
      end

      def person
        @person ||= person_class.find_by(id: person_id)
      end

      def attachment_url
        @attachment_url ||= begin
          return person_event.attachment_url unless attachment_file.present?

          FileUploadService.new(
            site: person.site,
            collection: person_event.model_name.collection,
            attribute_name: :attachment,
            file: attachment_file,
            content_disposition: "attachment"
          ).call
        end
      end

      def locations
        @locations ||= person_event.locations.presence || [build_person_event_location]
      end

      def locations_attributes=(attributes)
        @locations ||= []

        attributes.each do |_, location_attributes|
          next if location_attributes["_destroy"] == "1"

          location = person_event_location_class.new(
            name: location_attributes[:name],
            address: location_attributes[:address],
            lat: location_attributes[:lat],
            lng: location_attributes[:lng]
          )

          @locations.push(location) if location.valid?
        end
      end

      def attendees
        @attendees ||= person_event.attendees.presence || [build_person_event_attendee]

        if person_event.attendees.any?
          unless organizer = person_event.attendees.find_by(person_id: person_id)
            organizer = person_event_attendee_class.new(person_id: person_id)
          end
        else
          organizer = person_event_attendee_class.new(person_id: person_id)
        end
        @attendees.push(organizer) unless @attendees.include?(organizer)

        @attendees
      end

      def attendees_attributes=(attributes)
        @attendees ||= []

        attributes.each do |_, attendee_attributes|
          next if attendee_attributes["_destroy"] == "1"

          attendee = person_event_attendee_class.new(
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
          person_event_attributes.person_id = person_id
          person_event_attributes.site_id = site_id
          person_event_attributes.state = state
          person_event_attributes.title_translations = title_translations
          person_event_attributes.description_translations = description_translations
          person_event_attributes.starts_at = starts_at
          person_event_attributes.ends_at = ends_at
          person_event_attributes.attachment_url = attachment_url
          person_event_attributes.locations = locations
          person_event_attributes.attendees = attendees
        end

        if @person_event.valid?
          run_callbacks(:save) do
            @person_event.save
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
end
