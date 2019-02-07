# frozen_string_literal: true

module GobiertoPeople
  module Departments
    class PeopleController < BaseController

      layout "gobierto_people/layouts/departments"

      include DatesRangeHelper

      def index
        @people = QueryWithActivities.new(
          source: current_department.people.active,
          start_date: filter_start_date,
          end_date: filter_end_date,
          include_joins: { events: :attending_events, gifts: :received_gifts, invitations: :invitations, trips: :trips }
        ).sorted

        @sidebar_departments = current_site.departments

        filter_sidebar_departments if current_site.date_filter_configured?

        render "gobierto_people/people/index"
      end

      private

      def filter_sidebar_departments
        @sidebar_departments = @sidebar_departments.select do |department|
          events = department.events.published
          gifts = department.gifts
          trips = department.trips
          invitations = department.invitations

          if filter_start_date.present?
            events = events.where("starts_at >= ?", filter_start_date)
            gifts = gifts.where("date >= ?", filter_start_date)
            trips = trips.where("start_date >= ?", filter_start_date)
            invitations = invitations.where("start_date >= ?", filter_start_date)
          end

          if filter_end_date.present?
            events = events.where("ends_at <= ?", filter_end_date)
            gifts = gifts.where("date <= ?", filter_end_date)
            trips = trips.where("end_date <= ?", filter_end_date)
            invitations = invitations.where("end_date <= ?", filter_end_date)
          end
          events.exists? || gifts.exists? || trips.exists? || invitations.exists?
        end
      end
    end
  end
end
