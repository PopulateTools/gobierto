require "file_uploader/s3"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :person_id,
        :title,
        :description,
        :starts_at,
        :ends_at,
        :attachment_file,
        :attachment_url,
        :locations,
        :attendees
      )

      delegate :persisted?, to: :person_event

      validates :title, presence: true
      validates :starts_at, :ends_at, presence: true
      validates :person, presence: true

      def save
        save_person_event if valid?
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

          FileUploader::S3.new(
            file: attachment_file,
            file_name: "gobierto_people/people/#{person_id}/events/attachment-#{SecureRandom.uuid}"
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
            address: location_attributes[:address]
          )

          @locations.push(location) if location.valid?
        end
      end

      def attendees
        @attendees ||= person_event.attendees.presence || [build_person_event_attendee]
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
          person_event_attributes.title = title
          person_event_attributes.description = description
          person_event_attributes.starts_at = starts_at
          person_event_attributes.ends_at = ends_at
          person_event_attributes.attachment_url = attachment_url
          person_event_attributes.locations = locations
          person_event_attributes.attendees = attendees
        end

        if @person_event.valid?
          @person_event.save

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
