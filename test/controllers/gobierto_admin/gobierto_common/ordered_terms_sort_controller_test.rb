# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Configuration
      class OrderedTermsSortControllerTest < GobiertoControllerTest
        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def term1
          @term1 ||= gobierto_common_terms(:dog)
        end

        def term2
          @term2 ||= gobierto_common_terms(:cat)
        end

        def vocabulary
          @vocabulary ||= gobierto_common_vocabularies(:animals)
        end

        def setup
          super
          sign_in_admin(admin)
        end

        def teardown
          super
          sign_out_admin
        end

        def valid_sort_params
          {
            positions: {
              "0" => { id: term1.id, position: 2 },
              "1" => { id: term2.id, position: 1 }
            }
          }
        end

        def test_create
          assert_equal 0, term1.position
          assert_equal 1, term2.position

          post admin_common_vocabulary_terms_sort_url(vocabulary), params: valid_sort_params
          assert_response :no_content

          term1.reload
          term2.reload
          assert_equal 1, term2.position
          assert_equal 2, term1.position
        end
      end
    end
  end
end
