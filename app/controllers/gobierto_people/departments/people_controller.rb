# frozen_string_literal: true

module GobiertoPeople
  module Departments
    class PeopleController < BaseController

      layout "gobierto_people/layouts/departments"

      include DatesRangeHelper
      include FilterByActivitiesHelper

      def index
        @people = CollectionDecorator.new(
          current_department.people(start_date: filter_start_date, end_date: filter_end_date).includes(:historical_charges),
          decorator: GobiertoPeople::PersonDecorator
        )

        @sidebar_departments = current_site.departments

        filter_sidebar_departments if current_site.date_filter_configured?

        render "gobierto_people/people/index"
      end

      private

      def filter_sidebar_departments
        @sidebar_departments = filter_by_activities(
          source: @sidebar_departments,
          start_date: filter_start_date,
          end_date: filter_end_date
        )
      end
    end
  end
end
