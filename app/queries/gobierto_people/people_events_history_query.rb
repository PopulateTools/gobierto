# frozen_string_literal: true

module GobiertoPeople
  class PeopleEventsHistoryQuery < PeopleQuery

    def results
      relation.select("gp_people.*, to_char(gc_events.starts_at, 'YYYY/MM') AS year_month, COUNT(*) AS custom_events_count")
              .group("gp_people.id, year_month")
              .order("gp_people.position DESC, year_month ASC")
    end

  end
end
