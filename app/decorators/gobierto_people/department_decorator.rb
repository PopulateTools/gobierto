# frozen_string_literal: true

module GobiertoPeople
  class DepartmentDecorator < BaseDecorator

    attr_accessor(
      :object,
      :filter_start_date,
      :filter_end_date
    )

    def initialize(object, params = {})
      @object = object
      @filter_start_date = params[:filter_start_date]
      @filter_end_date = params[:filter_end_date]
    end

    def gifts
      @gifts ||= site.gifts
                     .where(person_id: people.pluck(:id))
                     .between_dates(filter_start_date, filter_end_date)
                     .limit(4)
    end

    def invitations
      @invitations ||= site.invitations
                           .where(person_id: people.pluck(:id))
                           .between_dates(filter_start_date, filter_end_date)
                           .limit(4)
    end

    def people
      @people ||= QueryWithEvents.new(
        source: object.people.active.with_event_attendances(site),
        start_date: filter_start_date,
        end_date: filter_end_date
      )
    end

    def meetings
      @meetings ||= QueryWithEvents.new(
        source: object.events.published,
        start_date: filter_start_date,
        end_date: filter_end_date
      )
    end

    def stats
      {
        total_people_with_attendances: people.count,
        total_meetings: meetings.count,
        unique_interest_groups: meetings.select(:interest_group_id).distinct.count
      }
    end

    def trips_count
      trips_query.count
    end

    def trips_unique_destinations_count
      trips_query.unique_destinations_count
    end

    private

    def trips_query
      GobiertoPeople::TripsQuery.new(
        department: object,
        start_date: filter_start_date,
        end_date: filter_end_date
      )
    end

  end
end
