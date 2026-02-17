# frozen_string_literal: true

require "test_helper"
require_relative "navigation_items"

module GobiertoPeople
  class PeopleIndexTest < ActionDispatch::IntegrationTest

    include NavigationItems

    def setup
      super
      @path = gobierto_people_people_path
      @path_for_json = gobierto_people_people_path(format: :json)
      @path_for_csv = gobierto_people_people_path(format: :csv)
    end

    def site
      @site ||= sites(:madrid)
    end

    def justice_department
      @justice_department ||= gobierto_people_departments(:justice_department)
    end

    def tourism_department_very_old
      @tourism_department_very_old ||= gobierto_people_departments(:tourism_department_very_old)
    end
    alias department_with_trips tourism_department_very_old

    def culture_department
      @culture_department ||= gobierto_people_departments(:culture_department)
    end
    alias department_with_gifts culture_department
    alias department_with_invitations culture_department

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
    alias person_with_gifts_and_department richard
    alias person_with_invitations_and_department richard
    alias person_with_trips_and_department richard

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end
    alias justice_department_person tamara

    def people
      @people ||= [
        richard,
        gobierto_people_people(:nelson),
        tamara,
        gobierto_people_people(:neil)
      ]
    end

    def political_groups
      @political_groups ||= [
        gobierto_common_terms(:marvel_term),
        gobierto_common_terms(:dc_term)
      ]
    end

    def departments
      @departments ||= [
        gobierto_people_departments(:justice_department),
        gobierto_people_departments(:culture_department),
        gobierto_people_departments(:ecology_department_old),
        gobierto_people_departments(:tourism_department_very_old),
        gobierto_people_departments(:immigration_department_mixed)
      ]
    end

    def departments_sidebar
      ".pure-u-1.pure-u-md-7-24"
    end

    def available_filters
      ["Government Team", "Opposition", "Executive", "All", "Political groups"]
    end

    def set_default_dates
      conf = site.configuration
      conf.raw_configuration_variables = <<-YAML
gobierto_people_default_filter_start_date: "2010-01-01"
YAML
      site.save
    end

    def clear_default_dates
      site.configuration.raw_configuration_variables = nil
      site.save
    end

    def clear_activities
      GobiertoPeople::Trip.destroy_all
      GobiertoPeople::Gift.destroy_all
      GobiertoPeople::Invitation.destroy_all
    end

    def test_people_index_with_departments_disabled
      disable_submodule(site, :departments)

      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "#{site.name}'s organization chart")

        within ".filter_boxed" do
          available_filters.each { |filter| assert has_link?(filter) }
        end
      end
    end

    def test_when_date_filering_enabled
      clear_activities

      disable_submodule(site, :departments)
      tamara.attending_events.destroy_all
      set_default_dates

      with_current_site(site) do
        visit @path

        within ".filter_boxed" do
          available_filters.each { |filter| assert has_link?(filter) }
        end

        within ".people-summary" do
          assert has_content? richard.name
          assert has_no_content? tamara.name # hide people without events
        end
      end
    end

    def test_when_date_filtering_disabled
      disable_submodule(site, :departments)
      tamara.attending_events.destroy_all
      clear_default_dates

      with_current_site(site) do
        visit @path

        within ".filter_boxed" do
          available_filters.each { |filter| assert has_link?(filter) }
        end

        within ".people-summary" do
          assert has_content? richard.name
          assert has_content? tamara.name # show people without events
        end
      end
    end

    def test_people_index_with_departments_enabled
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "#{site.name}'s organization chart")

        within departments_sidebar do
          departments.each { |department| assert has_link? department.name }
        end

        people.each { |person| assert has_link? person.name }
      end
    end

    def test_people_index_with_departments_enabled_and_date_filter
      clear_activities
      set_default_dates

      with_current_site(site) do
        visit gobierto_people_people_path(end_date: 50.years.ago)

        assert has_selector?("h2", text: "#{site.name}'s organization chart")

        within departments_sidebar do
          assert has_content? "There are no departments for this date range"
          departments.each { |department| assert has_no_link? department.name }
        end

        assert has_content? "There are no officials for this date range"
      end
    end

    def test_people_summary
      with_current_site(site) do
        visit @path

        within ".people-summary" do
          people.each do |person|
            assert has_selector?(".person-item", text: person.name)
            assert has_link?(person.name)
          end
        end
      end
    end

    def test_subscription_block
      skip "Subscription boxes are disabled"

      with_current_site(site) do
        visit @path

        within ".subscribable-box", match: :first do
          assert has_button?("Subscribe")
        end
      end
    end

    def test_people_index_json
      with_current_site(site) do
        get @path_for_json

        json_response = JSON.parse(response.body)
        assert_equal people.last.name, json_response.last["name"]
        assert_equal people.last.email, json_response.last["email"]
      end
    end

    def test_people_index_csv
      with_current_site(site) do
        get @path_for_csv

        csv_response = CSV.parse(response.body, headers: true)
        last_index = csv_response.by_row.length - 1
        assert_equal people.last.name, csv_response.by_row[last_index]["name"]
        assert_equal people.last.email, csv_response.by_row[last_index]["email"]
      end
    end

    def test_index_with_trips
      GobiertoCalendars::Event.destroy_all
      GobiertoPeople::Gift.destroy_all
      GobiertoPeople::Invitation.destroy_all

      set_default_dates
      start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

      with_current_site(site) do
        visit gobierto_people_people_path(
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

        within ".people-summary" do
          assert has_content? person_with_trips_and_department.name
        end
      end
    end

    def test_index_with_gifts
      GobiertoCalendars::Event.destroy_all
      GobiertoPeople::Invitation.destroy_all
      GobiertoPeople::Trip.destroy_all

      set_default_dates
      start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

      with_current_site(site) do
        visit gobierto_people_people_path(
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

        within ".people-summary" do
          assert has_content? person_with_gifts_and_department.name
        end
      end
    end

    def test_index_with_invitations
      GobiertoCalendars::Event.destroy_all
      GobiertoPeople::Gift.destroy_all
      GobiertoPeople::Trip.destroy_all

      set_default_dates
      start_date, end_date = [100.years.ago, 50.years.from_now].map { |d| d.strftime "%F" }

      with_current_site(site) do
        visit gobierto_people_people_path(
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

        within ".people-summary" do
          assert has_content? person_with_invitations_and_department.name
        end
      end
    end

  end
end
