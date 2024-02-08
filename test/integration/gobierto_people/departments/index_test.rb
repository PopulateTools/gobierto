# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module Departments
    class IndexTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def immigration_department
        @immigration_department ||= gobierto_people_departments(:immigration_department_mixed)
      end

      def culture_department
        @culture_department ||= gobierto_people_departments(:culture_department)
      end

      def set_default_dates
        conf = site.configuration
        conf.raw_configuration_variables = <<-YAML
gobierto_people_default_filter_start_date: "2010-01-01"
YAML
        site.save
      end

      def setup
        culture_department.events.each(&:destroy)
        super
      end

      def test_without_date_filtering_configured
        with_current_site(site) do
          visit gobierto_people_departments_path

          assert has_link? immigration_department.name
          assert has_link? culture_department.name
        end
      end

      def test_with_date_filtering_configured
        set_default_dates

        with_current_site(site) do
          visit gobierto_people_departments_path

          assert has_link? immigration_department.name
          assert has_no_link? culture_department.name
        end
      end

    end
  end
end
