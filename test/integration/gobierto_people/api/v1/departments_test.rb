# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module Api
    module V1
      class DepartmentsTest < ActionDispatch::IntegrationTest

        FAR_PAST = 10.years.ago.iso8601
        FAR_FUTURE = 10.years.from_now.iso8601

        def setup
          enable_submodule(madrid, :departments)
          super
        end

        def madrid
          @madrid ||= sites(:madrid)
        end

        def justice_department
          @justice_department ||= gobierto_people_departments(:justice_department)
        end

        def coca_cola
          @coca_cola ||= gobierto_people_interest_groups(:coca_cola)
        end

        def tamara
          @tamara ||= gobierto_people_people(:tamara)
        end

        def attributes
          %w(key value properties)
        end

        def departments_with_events_count
          ::GobiertoCalendars::Event.select(:department_id).distinct.count
        end

        def test_departments_index_test
          justice_department.update_attributes!(name: "Departament de la Presidència")

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
                from_date: FAR_PAST,
                to_date: FAR_FUTURE
              }
            )

            assert_response :success

            departments = JSON.parse(response.body)

            assert_equal 1, departments.size
            assert_equal departments.first["key"], justice_department.name
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
