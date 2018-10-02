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

    def richard
      @richard ||= gobierto_people_people(:richard)
    end

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

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
          refute has_content? tamara.name # hide people without events
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
        assert_equal json_response.last["name"], people.last.name
        assert_equal json_response.last["email"], people.last.email
      end
    end

    def test_people_index_csv
      with_current_site(site) do
        get @path_for_csv

        csv_response = CSV.parse(response.body, headers: true)
        last_index = csv_response.by_row.length - 1
        assert_equal csv_response.by_row[last_index]["name"], people.last.name
        assert_equal csv_response.by_row[last_index]["email"], people.last.email
      end
    end
  end
end
