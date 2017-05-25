# frozen_string_literal: true

module PersonEventHelpers
  def create_event(options = {})
    person = options[:person] || gobierto_people_people(:richard)
    site = person.site

    event = GobiertoPeople::PersonEvent.create!(
      person: person,
      title: options[:title] || 'Event title',
      description: 'Event description',
      starts_at: Time.zone.parse(options[:starts_at]) || Time.zone.now,
      ends_at:  (Time.zone.parse(options[:starts_at]) || Time.zone.now) + 1.hour,
      state: GobiertoPeople::PersonEvent.states['published'],
      site: site
    )

    event.attendees.create person: person

    event
  end
end
