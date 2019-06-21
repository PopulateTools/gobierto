# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Api
      class VocabulariesTest < ActionDispatch::IntegrationTest

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def vocabulary
          @vocabulary ||= gobierto_common_vocabularies(:animals)
        end

        def santander_vocabulary
          @santander_vocabulary ||= gobierto_common_vocabularies(:santander_vocabulary)
        end

        def test_show
          login_admin_for_api(admin)

          get admin_common_api_vocabulary_path(vocabulary)

          response_body = JSON.parse(response.body)

          assert_equal vocabulary.id, response_body["id"]
          assert_equal %w(id name_translations slug terms), response_body.keys
        end

        def test_show_from_other_site
          login_admin_for_api(admin)

          get admin_common_api_vocabulary_path(santander_vocabulary)

          response_body = JSON.parse(response.body)

          assert_equal({ "error" => "not-found" }, response_body)
        end

      end
    end
  end
end
