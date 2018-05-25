# frozen_string_literal: true

module GobiertoPeople
  class PersonEventForm < ::GobiertoCalendars::EventForm

    prepend ::GobiertoCommon::Trackable

    attr_accessor(
      :title,
      :description
    )

    validates :external_id, :title, presence: true
    validate :event_in_sync_range_window

    trackable_on :event
    notify_changed :state

    def initialize(options = {})
      ordered_options = HashWithIndifferentAccess.new(site_id: options[:site_id], person_id: options[:person_id])
      ordered_options.merge!(options)
      super(ordered_options)
    end

    def save
      save_event if valid?
    end

    def locations_attributes=(attributes)
      @locations = []

      attributes.each do |_, location_attributes|
        next if location_attributes["_destroy"] == "1"

        location = event.locations.detect{ |l| l.name == location_attributes[:name] } ||
          event_location_class.new(name: location_attributes[:name])

        @locations.push(location) if location.valid?
      end
    end

    def attendees=(attendees_attributes)
      @attendees = []

      attendees_attributes.each do |attendee_attributes|
        name  = attendee_attributes[:name]
        email = attendee_attributes[:email]

        attendee_person = attendee_attributes[:person] || site.people.find_by(email: email)

        existing_attendee = event.attendees.detect do |a|
          (attendee_person.present? && a.person == attendee_person) || a.name == name
        end

        attendee = if existing_attendee
                     existing_attendee
                   elsif attendee_person.present?
                     event_attendee_class.new(person: attendee_person)
                   else
                     event_attendee_class.new(name: name)
                   end

        @attendees.push(attendee) if attendee.valid?
      end
    end

    def state
      @state ||= event.state || "published"
    end

    def notify?
      notify && event.active? && person.present?
    end

    private

    def event_in_sync_range_window
      errors.add(:starts_at, 'is out of sync range') unless GobiertoCalendars.sync_range.cover?(starts_at)
    end

    def title_translations
      h = available_locales_to_hash
      h.merge({site.configuration.default_locale => title})
    end

    def description_translations
      h = available_locales_to_hash
      h.merge({site.configuration.default_locale => description})
    end

    def available_locales_to_hash
      Hash[I18n.available_locales.map {|x| [x, nil]}]
    end

    def save_event
      assign_event_attributes

      if @event.valid?
        if @event.changes.any?
          if notify?
            run_callbacks(:save) do
              @event.save
            end
          else
            @event.save
          end
        end

        @event
      else
        promote_errors(@event.errors)

        false
      end
    end
  end
end
