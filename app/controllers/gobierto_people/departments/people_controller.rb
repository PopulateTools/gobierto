# frozen_string_literal: true

module GobiertoPeople
  module Departments
    class PeopleController < BaseController

      layout "gobierto_people/layouts/departments"

      include DatesRangeHelper

      def index
        @people = QueryWithEvents.new(
          source: current_department.people.active,
          start_date: filter_start_date,
          end_date: filter_end_date
        ).sorted

        @sidebar_departments = QueryWithEvents.new(
          source: current_site.departments,
          start_date: filter_start_date,
          end_date: filter_end_date
        )

        render "gobierto_people/people/index"
      end

    end
  end
end
