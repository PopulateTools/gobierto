# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module Api
    class TermsControllerTest < GobiertoControllerTest
      def path
        @path ||= admin_common_api_vocabulary_terms_path(vocabulary)
      end

      def site
        @site ||= sites(:madrid)
      end

      def site_witout_terms_authorizations
        @site_witout_terms_authorizations ||= sites(:santander)
      end

      def vocabulary
        @vocabulary ||= gobierto_common_vocabularies(:madrid_political_groups_vocabulary)
      end

      def existing_term
        @existing_term ||= gobierto_common_terms(:dc_term)
      end

      def existing_term_from_other_vocabulary
        @existing_term_from_other_vocabulary ||= gobierto_common_terms(:culture_term)
      end

      def manager_admin
        gobierto_admin_admins(:nick)
      end

      def authorized_regular_admin
        gobierto_admin_admins(:tony)
      end

      def unauthorized_regular_admin
        gobierto_admin_admins(:steve)
      end

      def auth_header(admin)
        "Bearer #{admin.primary_api_token}"
      end

      def new_term_data
        @new_term_data ||= {
          "term": {
            "name_translations": {
              "es": "Bruguera",
              "en": "Bruguera & Co."
            }
          }
        }.with_indifferent_access
      end

      def existing_term_data
        @existing_term_data ||= {
          "term": {
            "name_translations": {
              "es": "DC",
              "en": "DC"
            }
          }
        }.with_indifferent_access
      end

      # Create
      #
      # POST /admin/api/vocabularies/1/terms
      # POST /admin/api/vocabularies/1/terms.json
      def test_create_without_token
        with(site: site) do
          post path, as: :json

          assert_response :unauthorized
          assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
        end
      end

      def test_create_invalid_token
        with(site: site) do
          auth_header = "Bearer WADUS"

          post(
            path,
            headers: { "Authorization" => auth_header },
            params: new_term_data,
            as: :json
          )
          assert_response :unauthorized
          assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
        end
      end

      def test_create_with_nil_api_token
        with(site: site) do
          auth_header = "Bearer "
          post(
            path,
            headers: { "Authorization" => auth_header },
            params: new_term_data,
            as: :json
          )
          assert_response :unauthorized
          assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
        end
      end

      def test_create_regular_admin_unauthorized
        with(site: site) do
          post(
            path,
            headers: { "Authorization" => auth_header(unauthorized_regular_admin) },
            params: new_term_data,
            as: :json
          )
          assert_response :unauthorized
          assert_equal({ "message" => "Module not allowed" }, response.parsed_body)
        end
      end

      def test_create_regular_admin_authorized
        with(site: site) do
          assert_difference "GobiertoCommon::Term.count", 1 do
            post(
              path,
              headers: { "Authorization" => auth_header(authorized_regular_admin) },
              params: new_term_data,
              as: :json
            )
          end

          assert_response :success

          response_data = response.parsed_body
          assert_equal(
            response_data["name_translations"],
            new_term_data["term"]["name_translations"]
          )
          assert response_data["id"].present?
        end
      end

      def test_create_regular_admin_authorized_with_existing_term
        with(site: site) do
          assert_difference "GobiertoCommon::Term.count", 0 do
            post(
              path,
              headers: { "Authorization" => auth_header(authorized_regular_admin) },
              params: existing_term_data,
              as: :json
            )
          end

          assert_response :success

          response_data = response.parsed_body
          assert_equal(
            response_data["name_translations"],
            existing_term.name_translations
          )
          assert_equal existing_term.id, response_data["id"].to_i
        end
      end
    end
  end
end
