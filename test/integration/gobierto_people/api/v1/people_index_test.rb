# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module Api
    module V1
      class PeopleIndexTest < ActionDispatch::IntegrationTest

        FAR_PAST = 10.years.ago.iso8601
        FAR_FUTURE = 10.years.from_now.iso8601

        def madrid
          @madrid ||= sites(:madrid)
        end

        def justice_department
          @justice_department ||= gobierto_people_departments(:justice_department)
        end

        def tamara
          @tamara ||= gobierto_people_people(:tamara)
        end

        def person_attributes
          %w(key value properties)
        end

        def people_attending_count
          ::GobiertoCalendars::EventAttendee.where(person_id: madrid.people.pluck(:id))
                                            .pluck(:person_id)
                                            .uniq.size
        end

        def people_with_events_on_justice_department
          [tamara]
        end

        def test_people_index_test
          with_current_site(madrid) do

            get gobierto_people_api_v1_people_path

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_attending_count, people.size

            assert array_match(person_attributes, people.first.keys)
          end
        end

        def test_people_index_with_filters_test
          with_current_site(madrid) do

            get(
              gobierto_people_api_v1_people_path,
              params: {
                department_id: justice_department.id,
                from_date: FAR_PAST,
                to_date: FAR_FUTURE
              }
            )

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_with_events_on_justice_department.size, people.size
            assert_equal people.first["key"], tamara.name
          end
        end

      end
    end
  end
end
