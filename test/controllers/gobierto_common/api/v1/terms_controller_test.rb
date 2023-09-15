# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module Api
    module V1
      class TermsControllerTest < GobiertoControllerTest
        def site
          @site ||= sites(:madrid)
        end

        def admin_token
          @admin_token ||= "Bearer #{gobierto_admin_api_tokens(:natasha_primary_api_token).token}"
        end

        def user_token
          @user_token ||= "Bearer #{user_api_tokens(:peter_primary_api_token).token}"
        end

        def vocabulary
          @vocabulary ||= gobierto_common_vocabularies(:animals)
        end

        def term
          @term ||= gobierto_common_terms(:cat)
        end

        def other_vocabulary_term
          @other_vocabulary_term ||= gobierto_common_terms(:culture_term)
        end

        def terms_count
          @terms_count ||= vocabulary.terms.count
        end

        def attributes_data(term)
          {
            name_translations: term.name_translations.presence || { "en" => nil, "es" => nil },
            description_translations: term.description_translations.presence || { "en" => nil, "es" => nil },
            slug: term.slug,
            position: term.position, # .to_s?
            level: term.level,
            term_id: term.term_id,
            parent_external_id: term.parent_external_id,
            external_id: term.external_id
          }.with_indifferent_access
        end

        def invalid_params
          {
            data:
            {
              type: "gobierto_common-terms",
              attributes:
              {
                "name_translations": nil,
                "slug": nil
              }
            }
          }
        end

        def valid_params
          {
            data:
            {
              type: "gobierto_common-term",
              attributes:
              {
                "name_translations": {
                  "en": "Sheep",
                  "es": "Oveja"
                },
                "slug": "sheep",
                parent_external_id: 1,
                external_id: "mammal-sheep"
              }
            }
          }
        end

        def update_valid_params
          {
            data:
            {
              type: "gobierto_common-term",
              attributes:
              {
                "external_id": 8,
                "name_translations": {
                  "en": "Kitty",
                  "es": "gatito"
                },
                "description_translations": {
                  "en": "A very small cat",
                  "es": "Un gato muy chiquitico"
                }
              }
            }
          }
        end

        def check_unauthorized
          with(site:) do
            yield

            assert_response :unauthorized
          end
        end

        # GET /api/v1/vocabularies/1/terms.json
        def test_index_without_token
          check_unauthorized { get gobierto_common_api_v1_vocabulary_terms_path(vocabulary), as: :json }
        end

        def test_index_with_user_token
          check_unauthorized { get gobierto_common_api_v1_vocabulary_terms_path(vocabulary), headers: { Authorization: user_token }, as: :json }
        end

        def test_index_with_admin_token
          with(site:) do
            get gobierto_common_api_v1_vocabulary_terms_path(vocabulary), headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal terms_count, response_data["data"].count
            terms_names = response_data["data"].map { |item| item.dig("attributes", "name_translations", "en") }
            assert_includes terms_names, term.name
            refute_includes terms_names, other_vocabulary_term.name
          end
        end

        # GET /api/v1/vocabularies/1/terms/1.json
        def test_show_without_token
          check_unauthorized { get gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), as: :json }
        end

        def test_show_with_user_token
          check_unauthorized { get gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), headers: { Authorization: user_token }, as: :json }
        end

        def test_show_with_admin_token
          with(site:) do
            get gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal term.id.to_s, resource_data["id"]
            assert_equal "gobierto_common-terms", resource_data["type"]

            attributes = attributes_data(term)

            %w(name_translations description_translations slug position level term_id parent_external_id external_id).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
              assert_equal attributes[attribute], resource_data["attributes"][attribute]
            end
          end
        end

        # GET /api/v1/vocabularies/1/terms/new.json
        def test_new_without_token
          check_unauthorized { get new_gobierto_common_api_v1_vocabulary_term_path(vocabulary), as: :json }
        end

        def test_new_with_user_token
          check_unauthorized { get new_gobierto_common_api_v1_vocabulary_term_path(vocabulary), headers: { Authorization: user_token }, as: :json }
        end

        def test_new_with_admin_token
          with(site:) do
            get new_gobierto_common_api_v1_vocabulary_term_path(vocabulary), headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal "gobierto_common-terms", resource_data["type"]
            refute response_data.has_key? "id"

            attributes = attributes_data(vocabulary.terms.new)

            %w(name_translations description_translations position level term_id parent_external_id external_id).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
              assert_equal attributes[attribute], resource_data["attributes"][attribute]
            end
            assert_nil resource_data["attributes"]["slug"]
          end
        end

        # POST /api/v1/vocabularies/1/terms.json
        def test_create_without_token
          assert_no_difference "GobiertoCommon::Term.count" do
            check_unauthorized { post gobierto_common_api_v1_vocabulary_terms_path(vocabulary), as: :json, params: valid_params }
          end
        end

        def test_create_with_user_token
          assert_no_difference "GobiertoCommon::Term.count" do
            check_unauthorized { post gobierto_common_api_v1_vocabulary_terms_path(vocabulary), headers: { Authorization: user_token }, as: :json, params: valid_params }
          end
        end

        def test_create_with_admin_token
          with(site:) do
            assert_difference "GobiertoCommon::Term.count", 1 do
              post gobierto_common_api_v1_vocabulary_terms_path(vocabulary), headers: { Authorization: admin_token }, as: :json, params: valid_params

              assert_response :created
              response_data = response.parsed_body

              new_term = GobiertoCommon::Term.last
              assert_equal vocabulary, new_term.vocabulary

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal new_term.id.to_s, resource_data["id"]
              assert_equal "gobierto_common-terms", resource_data["type"]

              # attributes
              attributes = attributes_data(new_term)
              %w(name_translations slug position level term_id parent_external_id external_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end
              assert_nil resource_data["attributes"]["description_translations"]
            end
          end
        end

        def test_create_with_admin_token_and_invalid_params
          with(site:) do
            assert_no_difference "GobiertoCommon::Term.count" do
              post gobierto_common_api_v1_vocabulary_terms_path(vocabulary), headers: { Authorization: admin_token }, as: :json, params: invalid_params

              assert_response :unprocessable_entity

              response_data = response.parsed_body
              assert response_data.has_key? "errors"
            end
          end
        end

        # PUT /api/v1/vocabularies/1/terms/1.json
        def test_update_without_token
          check_unauthorized { put gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), as: :json, params: update_valid_params }
        end

        def test_update_with_user_token
          check_unauthorized { put gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), headers: { Authorization: user_token }, as: :json, params: update_valid_params }
        end

        def test_update_with_admin_token
          with(site:) do
            assert_no_difference "GobiertoCommon::Term.count" do
              put gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), headers: { Authorization: admin_token }, as: :json, params: update_valid_params

              assert_response :success
              response_data = response.parsed_body

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              term.reload
              assert_equal term.id.to_s, resource_data["id"]
              assert_equal "gobierto_common-terms", resource_data["type"]
              assert_equal vocabulary, term.vocabulary

              # attributes
              attributes = attributes_data(term)
              %w(name_translations description_translations slug position level term_id parent_external_id external_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end
            end
          end
        end

        # DELETE /api/v1/vocabularies/1/terms/1.json
        def test_delete_without_token
          assert_no_difference "GobiertoCommon::Term.count" do
            check_unauthorized { delete gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), as: :json }
          end
        end

        def test_delete_with_user_token
          assert_no_difference "GobiertoCommon::Term.count" do
            check_unauthorized { delete gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), headers: { Authorization: user_token }, as: :json }
          end
        end

        def test_delete_with_admin_token
          id = term.id
          assert_difference "GobiertoCommon::Term.count", -1 do
            with(site:) do
              delete gobierto_common_api_v1_vocabulary_term_path(vocabulary, term), headers: { Authorization: admin_token }, as: :json

              assert_response :no_content

              assert_nil ::GobiertoCommon::Term.find_by(id: id)
            end
          end
        end
      end
    end
  end
end
