# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCalendars
    class EventForm < ::GobiertoCalendars::EventForm

      attr_accessor(
        :admin_id,
        :collection_id,
        :attachment_ids,
        :slug
      )

      trackable_on :event
      delegate :to_url, to: :event

      def ignored_constructor_attributes
        [:department_id, :meta]
      end

      def admin_id
        @admin_id ||= event.admin_id
      end

      def site_id
        @site_id ||= collection.try(:site_id)
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

      def attendees
        @attendees ||= event.attendees.presence || [build_event_attendee]
        super
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
        @starts_at ||= 1.hour.from_now.beginning_of_hour + 1.day
      end

      def ends_at
        @ends_at ||= starts_at + 1.hour
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

      def assign_event_attributes
        super.tap do |event_attributes|
          event_attributes.admin_id = admin_id
          event_attributes.slug = slug

          if event.new_record? && attachment_ids.present?
            if attachment_ids.is_a?(String)
              event_attributes.attachment_ids = attachment_ids.split(",")
            else
              event_attributes.attachment_ids = attachment_ids
            end
          end
        end
      end
    end
  end
end
