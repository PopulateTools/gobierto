# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Configuration
      class ScopesSortControllerTest < GobiertoControllerTest
        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def scope_1
          @scope_1 ||= gobierto_common_terms(:center_term)
        end

        def scope_2
          @scope_2 ||= gobierto_common_terms(:old_town_term)
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
              "0" => { id: scope_1.id, position: 2 },
              "1" => { id: scope_2.id, position: 1 }
            }
          }
        end

        def test_create
          assert_equal 1, scope_1.position
          assert_equal 2, scope_2.position

          post admin_scope_sort_url, params: valid_sort_params
          assert_response :no_content

          scope_1.reload
          scope_2.reload
          assert_equal 1, scope_2.position
          assert_equal 2, scope_1.position
        end
      end
    end
  end
end
