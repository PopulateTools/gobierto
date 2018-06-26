# frozen_string_literal: true

module GobiertoPeople
  module Departments
    class PeopleController < BaseController

      layout "gobierto_people/layouts/departments"

      def index
        @people = current_department.people.active.sorted

        render "gobierto_people/people/index"
      end

    end
  end
end
