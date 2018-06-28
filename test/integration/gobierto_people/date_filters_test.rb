# frozen_string_literal: true

require "test_helper"
require "support/gobierto_people/submodules_helper"
require "support/event_helpers"

module GobiertoPeople
  class DateFiltersTest < ActionDispatch::IntegrationTest
    include ::GobiertoPeople::SubmodulesHelper
    include ::EventHelpers

    FAR_PAST = 10.years.ago
    RECENT_PAST = 1.day.ago
    NEAR_FUTURE = 1.day.from_now
    FAR_FUTURE = 10.years.from_now

    attr_reader(
      :events_with_department,
      :events_without_department,
      :upcoming_events_with_department
    )

    def richard
      @richard ||= gobierto_people_people(:richard)
    end
    alias person_with_future_events richard

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end
    alias person_with_past_events tamara

    def neil
      @neil ||= gobierto_people_people(:neil)
    end

    def people_with_department_events
      [person_with_future_events, person_with_past_events]
    end

    def people_with_upcoming_department_events
      [person_with_future_events]
    end

    def setup
      enable_submodule(site, :departments)
      site.events.destroy_all
      @events_with_department = [
        create_event(person: tamara, department: department, starts_at: :past, title: "Past event 1"),
        create_event(person: richard, department: department, starts_at: :future, title: "Future event 1"),
        create_event(person: richard, department: department, starts_at: :future, title: "Future event 2")
      ]
      @events_without_department = [
        create_event(person: neil, department: nil)
      ]
      @upcoming_events_with_department = events_with_department.select(&:upcoming?)
      super
    end

    def department
      @department ||= gobierto_people_departments(:culture_department)
    end

    def set_site_dates(site, start_date: nil, end_date: nil)
      config_vars = {}
      config_vars[:gobierto_people_default_filter_start_date] = start_date if start_date
      config_vars[:gobierto_people_default_filter_end_date] = end_date if end_date
      site.configuration.raw_configuration_variables = config_vars.to_json.tr(",", "\n")
      site.save
    end

    def path_without_date_params
      gobierto_people_departments_path
    end

    def path_with_start_date(date)
      gobierto_people_departments_path(start_date: date)
    end

    def path_with_start_and_end_dates(start_date, end_date)
      gobierto_people_departments_path(start_date: start_date, end_date: end_date)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_site_without_default_dates_configured
      with_current_site(site) do
        # all events/people are counted
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end

        # all events/people are counted because date filters are ignored
        visit path_with_start_and_end_dates(NEAR_FUTURE, FAR_FUTURE)
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end
      end
    end

    def test_site_with_default_dates_configured
      set_site_dates(site, start_date: NEAR_FUTURE)

      with_current_site(site) do
        # all upcoming events/people with upcoming events are counted
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{upcoming_events_with_department.size} registered events"
          assert has_content? "#{people_with_upcoming_department_events.size} officials with registered events"
        end

        # all events/people are counted within broad range
        visit path_with_start_date(FAR_PAST)
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end

        # no events/people within very restrictive range
        visit path_with_start_and_end_dates(RECENT_PAST, NEAR_FUTURE)
        within ".container" do
          assert has_content? "0 registered events"
          assert has_content? "0 officials with registered events"
        end
      end
    end

    def test_date_filter_is_not_mantained_without_date_params
      set_site_dates(site, start_date: FAR_PAST)

      with_current_site(site) do
        # all events/people (default range)
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end

        # only upcoming events/people with upcoming events
        visit path_with_start_and_end_dates(NEAR_FUTURE, FAR_FUTURE)
        within ".container" do
          assert has_content? "#{upcoming_events_with_department.size} registered events"
          assert has_content? "#{people_with_upcoming_department_events.size} officials with registered events"
        end

        # all events/people (default range)
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end

        # no events/people (empty range)
        visit path_with_start_and_end_dates(RECENT_PAST, NEAR_FUTURE)
        within ".container" do
          assert has_content? "0 registered events"
          assert has_content? "0 officials with registered events"
        end

        # all events/people (default range)
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end
      end
    end

    def test_bad_date_params
      set_site_dates(site, start_date: FAR_PAST)

      with_current_site(site) do
        # all events/people (default range)
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end

        # all events/people (bad start_date and end_date)
        visit path_with_start_and_end_dates("wadus", "wadus")
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end

        # only upcoming events/people with upcoming events (ok start_date, bad end_date)
        visit path_with_start_and_end_dates(NEAR_FUTURE, "wadus")
        within ".container" do
          assert has_content? "#{upcoming_events_with_department.size} registered events"
          assert has_content? "#{people_with_upcoming_department_events.size} officials with registered events"
        end

        # all events/people (bad start_date)
        visit path_with_start_date("wadus")
        visit path_without_date_params
        within ".container" do
          assert has_content? "#{events_with_department.size} registered events"
          assert has_content? "#{people_with_department_events.size} officials with registered events"
        end
      end
    end
  end
end
