# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module Api
    module V1
      class VocabulariesControllerTest < GobiertoControllerTest
        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= admins(:natasha)
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

        def other_vocabulary
          @other_vocabulary ||= gobierto_common_vocabularies(:plan_categories_vocabulary)
        end

        def other_site_vocabulary
          @other_site_vocabulary ||= gobierto_common_vocabularies(:santander_vocabulary)
        end

        def vocabularies_count
          @vocabularies_count ||= site.vocabularies.count
        end

        def attributes_data(vocabulary)
          {
            name_translations: vocabulary.name_translations.presence || { "en" => nil, "es" => nil },
            slug: vocabulary.slug,
            terms: vocabulary.terms.exists? ? ActiveModelSerializers::SerializableResource.new(vocabulary.terms.sorted, each_serializer: ::GobiertoCommon::ApiTermSerializer).as_json : nil
          }.with_indifferent_access
        end

        def invalid_params
          {
            data:
            {
              type: "gobierto_common-vocabularies",
              attributes:
              {
                "name_translations": nil,
                "slug": nil
              }
            }
          }
        end

        def valid_params_without_terms
          {
            data:
            {
              type: "gobierto_common-vocabularies",
              attributes:
              {
                "name_translations": {
                  "ca": "Sense termes",
                  "en": "Without terms",
                  "es": "Sin términos"
                },
                "slug": "no-terms-0",
              }
            }
          }
        end

        def valid_params
          {
            data:
            {
              type: "gobierto_common-vocabularies",
              attributes:
              {
                "name_translations": {
                  "ca": "El nou vocabulari",
                  "en": "This is a totally new vocabulary",
                  "es": "Mi vocabulario nuevo del todo"
                },
                "slug": "nuevo-vocabulario-0",
                "terms": [
                  {
                    "name_translations": {
                      "ca": "",
                      "en": "",
                      "es": "Caballo"
                    },
                    "slug": "animales-caballo",
                    "position": 1,
                    "level": 2,
                    "parent_external_id": "TETRAPOD-1",
                    "external_id": "MAMMAL-1"
                  },
                  {
                    "name_translations": {
                      "ca": "",
                      "en": "",
                      "es": "Mamífero"
                    },
                    "slug": "animales-mamifero",
                    "position": 2,
                    "level": 1,
                    "parent_external_id": "VERTEBRATES",
                    "external_id": "TETRAPOD-1"
                  },
                  {
                    "name_translations": {
                      "ca": "",
                      "en": "",
                      "es": "Reptil"
                    },
                    "slug": "animales-reptil",
                    "position": 3,
                    "level": 1,
                    "parent_external_id": "VERTEBRATES",
                    "external_id": "TETRAPOD-2"
                  },
                  {
                    "name_translations": {
                      "ca": "",
                      "en": "",
                      "es": "Tortuga"
                    },
                    "slug": "animales-tortuga",
                    "position": 4,
                    "level": 2,
                    "parent_external_id": "TETRAPOD-2",
                    "external_id": "REPTILE-1"
                  },
                  {
                    "name_translations": {
                      "ca": "",
                      "en": "",
                      "es": "Gato"
                    },
                    "slug": "animales-gato",
                    "position": 4,
                    "level": 2,
                    "parent_external_id": "TETRAPOD-1",
                    "external_id": "MAMMAL-2"
                  },
                  {
                    "name_translations": {
                      "ca": "",
                      "en": "",
                      "es": "Vertebrado"
                    },
                    "slug": "animales-vertebrado",
                    "position": 5,
                    "level": 0,
                    "parent_external_id": nil,
                    "external_id": "VERTEBRATES"
                  }
                ]
              }
            }
          }
        end

        def update_valid_params
          {
            data:
            {
              attributes:
              {
                terms: [
                  {
                    "external_id": "ANIMALS",
                    "name_translations": {
                      "ca": "Animals",
                      "en": "Animals",
                      "es": "Animales"
                    },
                    "slug": "ANIMALS"
                  },
                  {
                    "external_id": 1,
                    "parent_external_id": "ANIMALS",
                    "name_translations": {
                      "en": "Mammal updated",
                      "es": "Mamífero actualizado"
                    },
                    "slug": "animals-mammal-updated"
                  },
                  {
                    "external_id": 4,
                    "parent_external_id": "ANIMALS",
                    "name_translations": {
                      "en": "Bird updated",
                      "es": "Pájaro actualizado"
                    }
                  },
                  {
                    "external_id": 2,
                    "slug": "animals-dog-updated"
                  }
                ]
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

        # GET /api/v1/vocabularies.json
        def test_index_without_token
          check_unauthorized { get gobierto_common_api_v1_vocabularies_path, as: :json }
        end

        def test_index_with_user_token
          check_unauthorized { get gobierto_common_api_v1_vocabularies_path, headers: { Authorization: user_token }, as: :json }
        end

        def test_index_with_admin_token
          with(site:) do
            get gobierto_common_api_v1_vocabularies_path, headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal vocabularies_count, response_data["data"].count
            vocabularies_names = response_data["data"].map { |item| item.dig("attributes", "name_translations", "en") }
            assert_includes vocabularies_names, vocabulary.name
            assert_includes vocabularies_names, other_vocabulary.name
            refute_includes vocabularies_names, other_site_vocabulary.name
          end
        end

        # GET /api/v1/vocabularies/1.json
        def test_show_without_token
          check_unauthorized { get gobierto_common_api_v1_vocabulary_path(vocabulary), as: :json }
        end

        def test_show_with_user_token
          check_unauthorized { get gobierto_common_api_v1_vocabulary_path(vocabulary), headers: { Authorization: user_token }, as: :json }
        end

        def test_show_with_admin_token
          with(site:) do
            get gobierto_common_api_v1_vocabulary_path(vocabulary), headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal vocabulary.id.to_s, resource_data["id"]
            assert_equal "gobierto_common-vocabularies", resource_data["type"]

            attributes = attributes_data(vocabulary)

            %w(name_translations slug terms).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
              assert_equal attributes[attribute], resource_data["attributes"][attribute]
            end
          end
        end

        # GET /api/v1/vocabularies/new.json
        def test_new_without_token
          check_unauthorized { get new_gobierto_common_api_v1_vocabulary_path, as: :json }
        end

        def test_new_with_user_token
          check_unauthorized { get new_gobierto_common_api_v1_vocabulary_path, headers: { Authorization: user_token }, as: :json }
        end

        def test_new_with_admin_token
          with(site:) do
            get new_gobierto_common_api_v1_vocabulary_path, headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal "gobierto_common-vocabularies", resource_data["type"]
            refute response_data.has_key? "id"

            attributes = attributes_data(site.vocabularies.new)

            assert_equal attributes["name_translations"], resource_data["attributes"]["name_translations"]
            assert_nil resource_data["attributes"]["slug"]
            assert_nil resource_data["attributes"]["terms"]
          end
        end

        # POST /api/v1/vocabularies.json
        def test_create_without_token
          assert_no_difference "GobiertoCommon::Vocabulary.count" do
            check_unauthorized { post gobierto_common_api_v1_vocabularies_path, as: :json, params: valid_params }
          end
        end

        def test_create_with_user_token
          assert_no_difference "GobiertoCommon::Vocabulary.count" do
            check_unauthorized { post gobierto_common_api_v1_vocabularies_path, headers: { Authorization: user_token }, as: :json, params: valid_params }
          end
        end

        def test_create_with_admin_token
          with(site:) do
            assert_difference "GobiertoCommon::Vocabulary.count", 1 do
              post gobierto_common_api_v1_vocabularies_path, headers: { Authorization: admin_token }, as: :json, params: valid_params

              assert_response :created
              response_data = response.parsed_body

              new_vocabulary = GobiertoCommon::Vocabulary.last

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal new_vocabulary.id.to_s, resource_data["id"]
              assert_equal "gobierto_common-vocabularies", resource_data["type"]

              # attributes
              attributes = attributes_data(new_vocabulary)
              %w(name_translations slug terms).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              # terms
              new_terms = new_vocabulary.terms

              assert_equal new_terms.find_by(external_id: "MAMMAL-1").term_id, new_terms.find_by(external_id: "TETRAPOD-1").id
              assert_equal new_terms.find_by(external_id: "REPTILE-1").term_id, new_terms.find_by(external_id: "TETRAPOD-2").id
              assert_equal new_terms.find_by(external_id: "TETRAPOD-1").term_id, new_terms.find_by(external_id: "VERTEBRATES").id
              assert_equal new_terms.find_by(external_id: "TETRAPOD-2").term_id, new_terms.find_by(external_id: "VERTEBRATES").id

              assert_equal 0, new_terms.find_by(external_id: "VERTEBRATES").level
              assert_equal 1, new_terms.find_by(external_id: "TETRAPOD-1").level
              assert_equal 2, new_terms.find_by(external_id: "MAMMAL-1").level
            end
          end
        end

        def test_create_with_admin_token_without_terms_param
          with(site:) do
            assert_difference "GobiertoCommon::Vocabulary.count", 1 do
              post gobierto_common_api_v1_vocabularies_path, headers: { Authorization: admin_token }, as: :json, params: valid_params_without_terms

              assert_response :created
              response_data = response.parsed_body

              new_vocabulary = GobiertoCommon::Vocabulary.last

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal new_vocabulary.id.to_s, resource_data["id"]
              assert_equal "gobierto_common-vocabularies", resource_data["type"]

              # attributes
              attributes = attributes_data(new_vocabulary)
              %w(name_translations slug).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              assert_nil resource_data["attributes"]["terms"]

              # terms
              refute new_vocabulary.terms.exists?
            end
          end
        end


        def test_create_with_admin_token_and_invalid_params
          with(site:) do
            assert_no_difference "GobiertoCommon::Vocabulary.count" do
              post gobierto_common_api_v1_vocabularies_path, headers: { Authorization: admin_token }, as: :json, params: invalid_params

              assert_response :unprocessable_entity

              response_data = response.parsed_body
              assert response_data.has_key? "errors"
            end
          end
        end

        # PUT /api/v1/vocabularies/1.json
        def test_update_without_token
          check_unauthorized { put gobierto_common_api_v1_vocabulary_path(vocabulary), as: :json, params: update_valid_params }
        end

        def test_update_with_user_token
          check_unauthorized { put gobierto_common_api_v1_vocabulary_path(vocabulary), headers: { Authorization: user_token }, as: :json, params: update_valid_params }
        end

        def test_update_with_admin_token
          with(site:) do
            assert_no_difference "GobiertoCommon::Vocabulary.count" do
              put gobierto_common_api_v1_vocabulary_path(vocabulary), headers: { Authorization: admin_token }, as: :json, params: update_valid_params

              assert_response :success
              response_data = response.parsed_body

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal vocabulary.id.to_s, resource_data["id"]
              assert_equal "gobierto_common-vocabularies", resource_data["type"]

              # attributes
              attributes = attributes_data(vocabulary)
              %w(name_translations slug terms).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              # terms
              terms = vocabulary.terms
              animals = terms.find_by(external_id: "ANIMALS")
              mammal = terms.find_by(slug: "animals-mammal-updated")
              bird = terms.find_by(slug: "animals-bird")
              dog = terms.find_by(slug: "animals-dog-updated")

              assert_equal 7, terms.count

              assert_equal 0, animals.level
              assert_equal animals.id, mammal.term_id
              assert_equal 1, mammal.level
              assert_equal animals.id, bird.term_id
              assert_equal 1, bird.level
              assert_equal mammal.id, dog.term_id
              assert_equal 2, dog.level

              assert_equal "Mammal updated", mammal.name
              assert_equal "Bird updated", bird.name
              assert_equal "Dog", dog.name
            end
          end
        end

        # DELETE /api/v1/vocabularies/1.json
        def test_delete_without_token
          assert_no_difference "GobiertoCommon::Vocabulary.count" do
            check_unauthorized { delete gobierto_common_api_v1_vocabulary_path(vocabulary), as: :json }
          end
        end

        def test_delete_with_user_token
          assert_no_difference "GobiertoCommon::Vocabulary.count" do
            check_unauthorized { delete gobierto_common_api_v1_vocabulary_path(vocabulary), headers: { Authorization: user_token }, as: :json }
          end
        end

        def test_delete_with_admin_token
          id = vocabulary.id
          assert_difference "GobiertoCommon::Vocabulary.count", -1 do
            with(site:) do
              delete gobierto_common_api_v1_vocabulary_path(vocabulary), headers: { Authorization: admin_token }, as: :json

              assert_response :no_content

              assert_nil ::GobiertoCommon::Vocabulary.find_by(id: id)
            end
          end
        end
      end
    end
  end
end
