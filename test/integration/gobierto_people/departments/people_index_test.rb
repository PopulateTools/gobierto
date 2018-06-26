# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module Departments
    class PeopleIndexTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def justice_department
        @justice_department ||= gobierto_people_departments(:justice_department)
      end

      def culture_department
        @culture_department ||= gobierto_people_departments(:culture_department)
      end

      def departments
        @departments ||= [justice_department, culture_department]
      end

      def richard
        @richard ||= gobierto_people_people(:richard)
      end
      alias culture_department_person richard

      def tamara
        @tamara ||= gobierto_people_people(:tamara)
      end
      alias justice_department_person tamara

      def departments_sidebar
        ".pure-u-1.pure-u-md-7-24"
      end

      def test_department_filters
        with_current_site(site) do

          visit gobierto_people_department_people_path(justice_department)

          within departments_sidebar do
            departments.each { |department| assert has_link? department.name }
          end

          assert has_link? justice_department_person.name
          assert has_no_link? culture_department_person.name

          within departments_sidebar do
            click_link culture_department.name
          end

          assert has_no_link? justice_department_person.name
          assert has_link? culture_department_person.name
        end
      end

    end
  end
end
