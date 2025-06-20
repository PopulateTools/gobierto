# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  module Api
    module V1
      class PeopleIndexTest < ActionDispatch::IntegrationTest

        include ::EventHelpers

        FAR_PAST = 100.years.ago.iso8601
        FAR_FUTURE = 100.years.from_now.iso8601

        attr_accessor(
          :madrid,
          :justice_department,
          :coca_cola_group,
          :tamara,
          :richard,
          :neil
        )

        def setup
          super
          @madrid = sites(:madrid)
          @justice_department = gobierto_people_departments(:justice_department)
          @coca_cola_group = gobierto_people_interest_groups(:coca_cola)
          @tamara = gobierto_people_people(:tamara)
          @richard = gobierto_people_people(:richard)
          @neil = gobierto_people_people(:neil)

          enable_submodule(madrid, :agendas)
        end

        def person_attributes
          %w(
            id name email position current_positions filtered_positions filtered_positions_str
            filtered_positions_html filtered_positions_tooltip bio bio_url
            avatar_url category political_group party url created_at updated_at
          )
        end

        def people_attending_count
          ::GobiertoCalendars::EventAttendee.where(person_id: madrid.people.pluck(:id))
                                            .pluck(:person_id)
                                            .uniq.size
        end

        def people_with_activity_on_justice_department
          [neil]
        end

        def people_with_events_on_coca_cola_group
          [tamara]
        end

        def people_with_gifts_invitations_or_trips
          [richard, tamara]
        end

        def people_with_old_gifts_invitations_or_trips
          [richard]
        end

        def short_date(date)
          date[/^\d+-\d+-\d+/]
        end

        def test_people_index_test
          with(site: madrid) do

            get gobierto_people_api_v1_people_path

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_attending_count, people.size

            assert array_match(person_attributes, people.first.keys)
          end
        end

        def test_people_index_with_filters_test
          with(site: madrid) do

            get(
              gobierto_people_api_v1_people_path,
              params: {
                department_id: justice_department.id,
                start_date: FAR_PAST,
                end_date: FAR_FUTURE
              }
            )

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_with_activity_on_justice_department.size, people.size
            assert_equal neil.name, people.first["name"]
            assert_match "?end_date=#{ short_date(FAR_FUTURE) }&start_date=#{ short_date(FAR_PAST) }", people.first["url"]
          end
        end

        def test_people_index_including_all_activities
          with(site: madrid) do
            GobiertoCalendars::Event.destroy_all

            get(
              gobierto_people_api_v1_people_path,
              params: {
                include_all_activities: true,
                start_date: 3.years.ago.iso8601,
                end_date: 1.year.ago.iso8601
              }
            )

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_with_old_gifts_invitations_or_trips.map(&:name).sort, people.map { |person| person["name"] }.sort

            get(
              gobierto_people_api_v1_people_path,
              params: {
                include_all_activities: true
              }
            )

            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_with_gifts_invitations_or_trips.map(&:name).sort, people.map { |person| person["name"] }.sort
          end
        end

        def test_people_index_with_interest_group_filter
          with(site: madrid) do
            get(
              gobierto_people_api_v1_people_path,
              params: {
                interest_group_id: coca_cola_group.id
              }
            )
            assert_response :success

            people = JSON.parse(response.body)

            assert_equal people_with_events_on_coca_cola_group.size, people.size
            assert_equal tamara.name, people.first["name"]
          end
        end

        def test_people_index_test_with_events_history
          tamara.attending_events.destroy_all
          create_event(person: tamara, starts_at: "15-01-2017")
          create_event(person: tamara, starts_at: "16-01-2017")

          with(site: madrid) do

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
              "value" => [
                {
                  "key" => Time.zone.parse("2017/01"),
                  "value" => 2,
                  "properties" => {
                    "url" => "http://www.example.com/en/agendas/tamara-devoux/eventos-pasados?end_date=2017-02-01&page=false&start_date=2017-01-01"
                  }
                }
              ],
              "properties" => {
                "url" => "http://www.example.com/en/agendas/tamara-devoux/eventos-pasados?page=false"
              }
            }

            assert_equal expected_tamara_data, tamara_data
          end
        end

        def test_people_index_test_with_submodule_disabled
          disable_submodule(madrid, :agendas)

          with(site: madrid) do
            get gobierto_people_api_v1_people_path

            assert_response :forbidden
          end
        end

      end
    end
  end
end
