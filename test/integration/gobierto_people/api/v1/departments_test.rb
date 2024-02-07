# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  module Api
    module V1
      class DepartmentsTest < ActionDispatch::IntegrationTest

        FAR_PAST = 10.years.ago.iso8601
        FAR_FUTURE = 10.years.from_now.iso8601

        include ::EventHelpers

        def setup
          enable_submodule(madrid, :departments)
          super
        end

        def madrid
          @madrid ||= sites(:madrid)
        end

        def culture_department
          @culture_department ||= gobierto_people_departments(:culture_department)
        end

        def tourism_department
          @tourism_department ||= gobierto_people_departments(:tourism_department_very_old)
        end

        def ecology_department
          @ecology_department ||= gobierto_people_departments(:ecology_department_old)
        end

        def coca_cola
          @coca_cola ||= gobierto_people_interest_groups(:coca_cola)
        end

        def richard
          @richard ||= gobierto_people_people(:richard)
        end

        def tamara
          @tamara ||= gobierto_people_people(:tamara)
        end

        def attributes
          %w(key value properties)
        end

        def departments_with_events_count
          madrid.events.map(&:historical_department).compact.uniq.count
        end

        def short_date(date)
          date[/^\d+-\d+-\d+/]
        end

        def test_departments_index_test
          culture_department.update!(name: "Departament de la Presidència")

          with_current_site(madrid) do

            get gobierto_people_api_v1_departments_path

            assert_response :success

            departments = JSON.parse(response.body)
            departments_names = departments.map { |d| d["key"] }

            assert_equal departments_with_events_count, departments.size
            assert departments_names.include?("Presidència")
            refute departments_names.include?("Departament de la Presidència")

            assert array_match(attributes, departments.first.keys)
          end
        end

        def test_departments_index_with_filters_test
          with_current_site(madrid) do

            get(
              gobierto_people_api_v1_departments_path,
              params: {
                interest_group_id: coca_cola.id,
                person_id: tamara.id,
                start_date: FAR_PAST,
                end_date: FAR_FUTURE
              }
            )

            assert_response :success

            departments = JSON.parse(response.body)

            assert_equal 1, departments.size
            assert_equal departments.first["key"], tourism_department.name
            assert_match "?end_date=#{ short_date(FAR_FUTURE) }&start_date=#{ short_date(FAR_PAST) }", departments.first["properties"]["url"]
          end
        end

        def test_departments_index_test_with_events_history
          ::GobiertoCalendars::Event.destroy_all
          culture_department.update!(name: "Departament de Cultura")

          create_event(person: richard, starts_at: "15-01-1970") # As alien doctor in ecology department old
          create_event(person: richard, starts_at: "16-01-2000") # As avenger in tourism department very old

          with_current_site(madrid) do

            get(
              gobierto_people_api_v1_departments_path,
              params: { include_history: true }
            )

            assert_response :success

            departments = JSON.parse(response.body)

            assert_equal [ecology_department, tourism_department].size, departments.size

            tourism_department_data = departments.detect { |item| item["key"] == tourism_department.short_name }

            expected_tourism_department_data = {
              "key" => tourism_department.short_name,
              "value" => [
                {
                  "key" => Time.zone.parse("2000/01"),
                  "value" => 1,
                  "properties" => {
                    "url" => "/en/departments/toursim-department-very-old?end_date=2000-02-01&start_date=2000-01-01"
                  }
                }
              ],
              "properties" => {
                "url" => "/en/departments/toursim-department-very-old?page=false"
              }
            }

            assert_equal expected_tourism_department_data, tourism_department_data
          end
        end

        def test_departments_index_test_with_submodule_disabled
          disable_submodule(madrid, :departments)

          with_current_site(madrid) do
            get gobierto_people_api_v1_departments_path

            assert_response :forbidden
          end
        end

      end
    end
  end
end
