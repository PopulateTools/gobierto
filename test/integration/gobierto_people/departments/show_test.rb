# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module Departments
    class ShowTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def department
        @department ||= gobierto_people_departments(:justice_department)
      end

      def test_show
        with_current_site(site) do
          visit gobierto_people_department_path(department)

          assert has_content? department.name
        end
      end

    end
  end
end
