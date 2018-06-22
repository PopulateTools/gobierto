# frozen_string_literal: true

module EventHelpers

  def create_event(options = {})
    person     = options[:person] || gobierto_people_people(:richard)
    collection = person.events_collection
    site       = options[:site] || sites(:madrid)

    event = GobiertoCalendars::Event.create!(
      title: options[:title] || "Event title",
      description: "Event description",
      starts_at: parse_start_date(options),
      ends_at: parse_end_date(options),
      state: GobiertoCalendars::Event.states["published"],
      collection: collection,
      external_id: options[:external_id].presence,
      site: site
    )

    event.attendees.create person: person

    event
  end

  private

  def parse_start_date(options)
    starts_at_param = options[:starts_at]
    if starts_at_param && starts_at_param.is_a?(String)
      Time.zone.parse(starts_at_param)
    elsif starts_at_param
      starts_at_param
    else
      Time.zone.now
    end
  end

  def parse_end_date(options)
    ends_at_param = options[:ends_at]
    if ends_at_param && ends_at_param.is_a?(String)
      Time.zone.parse(ends_at_param)
    elsif ends_at_param
      ends_at_param
    else
      parse_start_date(options) + 1.hour
    end
  end

end
