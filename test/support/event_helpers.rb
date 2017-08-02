module EventHelpers

  def create_event(options = {})
    person = options[:person] || gobierto_people_people(:richard)
    collection = person.events_collection
    site = options[:site] || sites(:madrid)

    event = GobiertoCalendars::Event.create!(
      title: options[:title] || "Event title",
      description: "Event description",
      starts_at: Time.zone.parse(options[:starts_at]) || Time.zone.now,
      ends_at:  (Time.zone.parse(options[:starts_at]) || Time.zone.now) + 1.hour,
      state: GobiertoCalendars::Event.states["published"],
      collection: collection,
      site: site
    )

    event.attendees.create person: person

    event
  end

end
