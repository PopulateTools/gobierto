# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"
require "support/gobierto_people/submodules_helper"

module GobiertoPeople
  module Api
    module V1
      class PeopleIndexTest < ActionDispatch::IntegrationTest

        include ::EventHelpers
        include ::GobiertoPeople::SubmodulesHelper

        FAR_PAST = 10.years.ago.iso8601
        FAR_FUTURE = 10.years.from_now.iso8601

        def setup
          enable_submodule(madrid, :agendas)
          super
        end

        def madrid
          @madrid ||= sites(:madrid)
        end

        def justice_department
          @justice_department ||= gobierto_people_departments(:justice_department)
        end

        def coca_cola_group
          @coca_cola_group ||= gobierto_people_interest_groups(:coca_cola)
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

        def people_with_events_on_coca_cola_group
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

        def test_people_index_with_interest_group_filter
          with_current_site(madrid) do
            get(
              gobierto_people_api_v1_people_path,
              params: {
                interest_group_id: coca_cola_group.id
              }
            )
            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_with_events_on_coca_cola_group.size, people.size
            assert_equal people.first["key"], tamara.name
          end
        end

        def test_people_index_test_with_events_history
          tamara.attending_events.destroy_all
          create_event(person: tamara, starts_at: "15-01-2017")
          create_event(person: tamara, starts_at: "16-01-2017")

          with_current_site(madrid) do

            get(
              gobierto_people_api_v1_people_path,
              params: { include_history: true }
            )

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_attending_count, people.size

            tamara_data = people.detect { |item| item["key"] == tamara.name }

            expected_tamara_data = {
              "key" => tamara.name,
              "value" => [{ "key" => Time.zone.parse("2017/01"), "value" => 2 }]
            }

            assert_equal expected_tamara_data, tamara_data
          end
        end

        def test_people_index_test_with_submodule_disabled
          disable_submodule(madrid, :agendas)

          with_current_site(madrid) do
            get gobierto_people_api_v1_people_path

            assert_response :forbidden
          end
        end

      end
    end
  end
end
