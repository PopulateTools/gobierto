# frozen_string_literal: true

module GobiertoCalendars
  class EventForm < BaseForm

    prepend ::GobiertoCommon::Trackable

    attr_accessor(
      :id,
      :external_id,
      :site_id,
      :person_id,
      :title_translations,
      :description_translations,
      :description_source_translations,
      :starts_at,
      :ends_at,
      :notify,
      :meta,
      :department_id,
      :interest_group_id,
    )
    attr_writer(
      :state,
      :locations,
      :attendees
    )

    delegate :persisted?, to: :event

    validates :starts_at, :ends_at, :site, :collection, presence: true
    validates :title_translations, translated_attribute_presence: true

    trackable_on :event

    notify_changed :state

    def initialize(options = {})
      options = options.to_h.with_indifferent_access
      super options.except(*ignored_constructor_attributes)
    end

    def ignored_constructor_attributes
      []
    end

    def destroy
      unless event.new_record?
        event.destroy
      end
    end

    def save
      save_event if valid?
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def event
      @event ||= event_class.find_by(id: id).presence || external_id && person.events.find_by(external_id: external_id).presence || build_event
    end

    def person
      @person ||= site.people.find_by(id: person_id)
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
        location = event_location_class.new(location_attributes.slice(:name, :address, :lat, :lng))
        @locations.push(location) if location.valid?
      end
    end

    def attendees
      @attendees ||= event.attendees.presence || []
      return @attendees if person.nil? || @attendees.map(&:person_id).include?(person.id)
      @attendees.push(organizer)
    end

    def organizer
      event.attendees.find_by(person_id: person.id).presence || event_attendee_class.new(person_id: person.id)
    end

    def state
      @state ||= event.state
    end

    def slug=(value)
      @slug = value.presence
    end

    def slug
      @slug ||= event.slug
    end

    def notify?
      notify && event.active? && person.present?
    end

    private

    def build_event
      event_class.new site_id: site_id
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

    def assign_event_attributes
      @event = event.tap do |event_attributes|
        event_attributes.external_id = external_id
        event_attributes.collection = collection
        event_attributes.site_id = site_id
        event_attributes.state = state
        event_attributes.title_translations = title_translations
        event_attributes.description_translations = description_translations&.transform_values { |value| sanitize(value) }
        event_attributes.description_source_translations = description_source_translations&.transform_values { |value| sanitize(value) }
        event_attributes.starts_at = starts_at
        event_attributes.ends_at = ends_at
        event_attributes.meta = meta
        event_attributes.department_id = department_id
        event_attributes.interest_group_id = interest_group_id
        event_attributes.locations = locations
        event_attributes.attendees = attendees
        event_attributes.slug = slug
      end
    end

    def save_event
      assign_event_attributes

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

    private

    def sanitizer
      @sanitizer ||= Rails::Html::FullSanitizer.new
    end

    def sanitize(value)
      sanitizer.sanitize(value)
    end
  end
end
