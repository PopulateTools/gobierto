# frozen_string_literal: true

module EventHelpers

  TIME_ALIASES = {
    past: 1.year.ago,
    far_past: 10.years.ago,
    future: 1.year.from_now,
    far_future: 10.years.from_now
  }.freeze

  def create_event(options = {})
    person     = options[:person] || gobierto_people_people(:richard)
    collection = person.events_collection
    site       = options[:site] || sites(:madrid)

    event = GobiertoCalendars::Event.create!(
      title: options[:title] || "Event title",
      description: "Event description",
      starts_at: parse_start_date(options),
      ends_at: parse_end_date(options),
      state: parse_state(options),
      collection: collection,
      external_id: options[:external_id],
      interest_group_id: interest_group_id(options),
      department_id: department_id(options),
      site: site
    )

    event.attendees.create person: person

    event
  end

  private

  def parse_start_date(options)
    starts_at_param = options[:starts_at]
    if starts_at_param && TIME_ALIASES[starts_at_param]
      TIME_ALIASES[starts_at_param]
    elsif starts_at_param&.is_a?(String)
      Time.zone.parse(starts_at_param)
    elsif starts_at_param
      starts_at_param
    else
      Time.zone.now
    end
  end

  def parse_end_date(options)
    ends_at_param = options[:ends_at]
    if ends_at_param&.is_a?(String)
      Time.zone.parse(ends_at_param)
    elsif ends_at_param
      ends_at_param
    else
      parse_start_date(options) + 1.hour
    end
  end

  def parse_state(options)
    GobiertoCalendars::Event.states[
      (options[:state].to_s == "pending") ? "pending" : "published"
    ]
  end

  def interest_group_id(options)
    return nil unless options[:interest_group]

    options[:interest_group].try(:id) || defaults[:interest_group].id
  end

  def department_id(options)
    return nil unless options[:department]

    options[:department].try(:id) || defaults[:department].id
  end

  def defaults
    {
      interest_group: gobierto_people_interest_groups(:google),
      department: gobierto_people_departments(:justice_department)
    }
  end

end
