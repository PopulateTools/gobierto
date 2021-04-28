# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module Api
    module V1
      class SearchControllerTest < GobiertoControllerTest

        attr_reader :searchable_types

        def setup
          super
          @searchable_types = JSON.parse(GobiertoCommon::Search.new(site).searchable_types) - ["GobiertoBudgets::BudgetLine"]

          searchable_types.each { |searchable_type| PgSearch::Multisearch.rebuild(searchable_type.constantize) }
        end

        def site
          @site ||= sites(:madrid)
        end

        def other_site
          @other_site ||= sites(:santander)
        end

        def person
          @person ||= gobierto_people_people(:nelson)
        end

        def person_statement
          @person_statement ||= gobierto_people_person_statements(:nelson_current)
        end

        def published_event
          @published_event ||= gobierto_calendars_events(:richard_published)
        end

        def pending_event
          @pending_event ||= gobierto_calendars_events(:richard_pending)
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end

        def results_include?(response_data, resource)
          response_data["data"].find do |hit|
            hit["attributes"]["searchable_type"] == resource.class.name && hit["attributes"]["searchable_id"] == resource.id
          end.present?
        end

        # GET /api/v1/search
        # GET /api/v1/search.json
        def test_empty_query
          with(site: site) do
            get gobierto_common_api_v1_search_path

            assert_response :success

            response_data = response.parsed_body
            assert response_data.has_key? "data"
            assert response_data["data"].blank?
          end
        end

        # GET /api/v1/search?query=Nelson
        # GET /api/v1/search.json?query=Nelson
        def test_query
          with(site: site) do
            get gobierto_common_api_v1_search_path(query: person.name)

            assert_response :success

            response_data = response.parsed_body
            assert response_data.has_key? "data"
            refute response_data["data"].blank?

            assert results_include?(response_data, person)
          end
        end

        # GET /api/v1/search?query=Nelson
        # GET /api/v1/search.json?query=Nelson
        def test_query_in_other_site
          with(site: other_site) do
            get gobierto_common_api_v1_search_path(query: person.name)

            assert_response :success

            response_data = response.parsed_body
            assert response_data["data"].blank?
          end
        end

        def test_query_filtered_by_type
          with(site: site) do
            get gobierto_common_api_v1_search_path(query: "nelson")
            total_response_data = response.parsed_body
            get gobierto_common_api_v1_search_path(query: "nelson", filters: { searchable_type: ["GobiertoPeople::PersonStatement"] })
            filtered_response_data = response.parsed_body

            assert results_include?(total_response_data, person)
            assert results_include?(total_response_data, person_statement)
            refute results_include?(filtered_response_data, person)
            assert results_include?(filtered_response_data, person_statement)
          end
        end

        def test_query_filtered_by_type_datasets
          with(site: site, dataset: dataset) do
            get gobierto_common_api_v1_search_path(query: "Users")
            total_response_data = response.parsed_body
            get gobierto_common_api_v1_search_path(query: "Users", filters: { searchable_type: ["GobiertoData::Dataset"] })
            filtered_response_data = response.parsed_body

            assert results_include?(total_response_data, dataset)
            assert results_include?(filtered_response_data, dataset)
          end
        end

        def test_query_event_by_publication_status
          with(site: site) do
            get gobierto_common_api_v1_search_path(query: pending_event.title)
            response_data = response.parsed_body

            refute results_include?(response_data, pending_event)

            get gobierto_common_api_v1_search_path(query: published_event.title)
            response_data = response.parsed_body

            assert results_include?(response_data, published_event)
          end
        end
      end
    end
  end
end
