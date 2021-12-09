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
      alias department_with_gifts culture_department
      alias department_with_invitations culture_department

      def ecology_department_old
        @ecology_department_old ||= gobierto_people_departments(:ecology_department_old)
      end

      def tourism_department_very_old
        @tourism_department_very_old ||= gobierto_people_departments(:tourism_department_very_old)
      end
      alias department_with_trips tourism_department_very_old

      def immigration_department_mixed
        @immigration_department_mixed ||= gobierto_people_departments(:immigration_department_mixed)
      end

      def set_default_dates(options = {})
        conf = site.configuration
        conf.raw_configuration_variables = <<-YAML
gobierto_people_default_filter_start_date: "#{options[:start_date]}"
gobierto_people_default_filter_end_date: "#{options[:end_date]}"
YAML
        site.save
      end

      def departments
        @departments ||= [
          justice_department,
          culture_department,
          ecology_department_old,
          tourism_department_very_old,
          immigration_department_mixed
        ]
      end

      def departments_with_trips
        @departments_with_trips ||= [department_with_trips, culture_department]
      end

      def departments_with_gifts
        @departments_with_gifts ||= [department_with_gifts, tourism_department_very_old]
      end

      def departments_with_invitations
        @departments_with_invitations ||= [department_with_invitations, tourism_department_very_old]
      end

      def richard
        @richard ||= gobierto_people_people(:richard)
      end
      alias culture_department_person richard
      alias person_with_gifts_and_department richard
      alias person_with_invitations_and_department richard
      alias person_with_trips_and_department richard

      def juana
        @juana ||= gobierto_people_people(:juana)
      end
      alias justice_department_person juana

      def neil
        @neil ||= gobierto_people_people(:neil)
      end

      def departments_sidebar
        ".pure-u-1.pure-u-md-7-24"
      end

      def people_summary
        ".people-summary"
      end

      def clear_activities
        GobiertoPeople::Trip.destroy_all
        GobiertoPeople::Gift.destroy_all
        GobiertoPeople::Invitation.destroy_all
      end

      def test_sidebar_contents
        clear_activities
        culture_department.events.each(&:destroy)

        with_current_site(site) do
          # without date filtering configured
          visit gobierto_people_department_people_path(justice_department)

          within departments_sidebar do
            assert has_link? justice_department.name
            assert has_link? culture_department.name
          end
        end
      end

      def test_sidebar_contents_with_date_filtering
        clear_activities
        culture_department.events.each(&:destroy)

        with_current_site(site) do
          # with date filtering configured
          set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
          visit gobierto_people_department_people_path(justice_department)

          within departments_sidebar do
            assert has_link? justice_department.name
            assert has_no_link? culture_department.name
          end
        end
      end

      def test_index
        clear_activities
        with_current_site(site) do
          visit gobierto_people_department_people_path(justice_department)

          within departments_sidebar do
            departments.each { |department| assert has_link? department.name }
          end

          assert has_link? justice_department_person.name
          assert has_no_link? culture_department_person.name
        end
      end

      def test_sidebar_in_department_page
        clear_activities
        with_current_site(site) do
          visit gobierto_people_department_people_path(justice_department)

          within departments_sidebar do
            click_link culture_department.name
          end

          assert has_no_link? justice_department_person.name
          assert has_link? culture_department_person.name
        end
      end

      def test_index_filtered_by_date_visit_departments_sidebar
        clear_activities
        site.events.where.not(id: neil.events.pluck(:id)).destroy_all

        with_current_site(site) do
          visit gobierto_people_department_people_path(immigration_department_mixed)

          # all departments are shown when filter is not configured

          within departments_sidebar do
            departments.each { |department| assert has_link? department.name }
          end
        end
      end

      def test_index_filtered_by_date_visit_departments_people
        clear_activities
        site.events.where.not(id: neil.events.pluck(:id)).destroy_all

        with_current_site(site) do
          set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")

          # nothing is displayed when out of range

          visit gobierto_people_department_people_path(
            immigration_department_mixed,
            start_date: 100.years.ago,
            end_date: 50.years.ago
          )

          within departments_sidebar do
            assert has_content? "There are no departments for this date range"
            departments.each { |department| assert has_no_link? department.name }
          end

          assert has_content? "There are no officials for this date range"
        end
      end

      def test_index_filtered_by_date_visit_departments_people_check_sidebar
        clear_activities
        site.events.where.not(id: neil.events.pluck(:id)).destroy_all

        departments_with_activities = [
          immigration_department_mixed,
          justice_department
        ]

        with_current_site(site) do
          set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
          # everything is displayed with broad range

          start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

          visit gobierto_people_department_people_path(
            immigration_department_mixed,
            start_date: start_date,
            end_date: end_date
          )

          within departments_sidebar do
            departments_with_activities.each do |department|
              assert has_link? department.name
              assert has_link_to? gobierto_people_department_people_path(department.slug, start_date: start_date, end_date: end_date)
            end
          end
        end
      end

      def test_index_filtered_by_date_visit_departments_people_check_sidebar_other_dates
        clear_activities
        site.events.where.not(id: neil.events.pluck(:id)).destroy_all

        with_current_site(site) do
          set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
          # only departments with recent events are displayed

          visit gobierto_people_department_people_path(
            immigration_department_mixed,
            start_date: 2.months.ago,
            end_date: 2.months.from_now
          )

          within departments_sidebar do
            assert has_no_link? ecology_department_old.name
            assert has_no_link? tourism_department_very_old.name
            assert has_link? immigration_department_mixed.name
          end
        end
      end

      def test_index_filtered_by_date_visit_departments_people_check_sidebar_other_dates_in_past
        clear_activities
        site.events.where.not(id: neil.events.pluck(:id)).destroy_all

        with_current_site(site) do
          set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
          # only departments with very old events are displayed

          visit gobierto_people_department_people_path(
            immigration_department_mixed,
            start_date: 10.years.ago - 1.day,
            end_date: 10.years.ago + 1.day
          )

          within departments_sidebar do
            assert has_no_link? ecology_department_old.name
            assert has_no_link? tourism_department_very_old.name
            assert has_no_link? immigration_department_mixed.name
            assert has_link? justice_department.name
          end
        end
      end

      def test_index_with_trips
        GobiertoCalendars::Event.destroy_all
        GobiertoPeople::Gift.destroy_all
        GobiertoPeople::Invitation.destroy_all
        set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
        start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

        with_current_site(site) do
          visit gobierto_people_department_people_path(
            department_with_trips,
            start_date: start_date,
            end_date: end_date
          )
          within departments_sidebar do
            departments.each do |department|
              if departments_with_trips.include?(department)
                assert has_link? department.name
              else
                assert has_no_link? department.name
              end
            end
          end

          within people_summary do
            assert has_content? person_with_trips_and_department.name
          end
        end
      end

      def test_index_with_gifts
        GobiertoCalendars::Event.destroy_all
        GobiertoPeople::Trip.destroy_all
        GobiertoPeople::Invitation.destroy_all
        set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
        start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

        with_current_site(site) do
          visit gobierto_people_department_people_path(
            department_with_gifts,
            start_date: start_date,
            end_date: end_date
          )
          within departments_sidebar do
            departments.each do |department|
              if departments_with_gifts.include?(department)
                assert has_link? department.name
              else
                assert has_no_link? department.name
              end
            end
          end

          within people_summary do
            assert has_content? person_with_gifts_and_department.name
          end
        end
      end

      def test_index_with_invitations
        GobiertoCalendars::Event.destroy_all
        GobiertoPeople::Gift.destroy_all
        GobiertoPeople::Trip.destroy_all
        set_default_dates(start_date: "2010-01-01", end_date: "2020-01-01")
        start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

        with_current_site(site) do
          visit gobierto_people_department_people_path(
            department_with_invitations,
            start_date: start_date,
            end_date: end_date
          )
          within departments_sidebar do
            departments.each do |department|
              if departments_with_invitations.include?(department)
                assert has_link? department.name
              else
                assert has_no_link? department.name
              end
            end
          end

          within people_summary do
            assert has_content? person_with_invitations_and_department.name
          end
        end
      end
    end
  end
end
