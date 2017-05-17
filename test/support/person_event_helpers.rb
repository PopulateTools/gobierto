module PersonEventHelpers

  def create_event(options = {})
    GobiertoPeople::PersonEvent.create!(
      person: options[:person] || gobierto_people_people(:richard),
      site: options[:site] || sites(:madrid),
      title: options[:title] || "Event title",
      description: "Event description",
      starts_at: Time.zone.parse(options[:starts_at]) || Time.zone.now,
      ends_at:  (Time.zone.parse(options[:starts_at]) || Time.zone.now) + 1.hour,
      state: GobiertoPeople::PersonEvent.states["published"]
    )
  end

end
