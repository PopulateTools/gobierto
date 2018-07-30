# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    module Configuration
      class IssuesSortControllerTest < GobiertoControllerTest
        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def issue_1
          @issue_1 ||= gobierto_common_terms(:culture_term)
        end

        def issue_2
          @issue_2 ||= gobierto_common_terms(:women_term)
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
              "0" => { id: issue_1.id, position: 2 },
              "1" => { id: issue_2.id, position: 1 }
            }
          }
        end

        def test_create
          assert_equal 1, issue_1.position
          assert_equal 2, issue_2.position

          post admin_issue_sort_url, params: valid_sort_params
          assert_response :no_content

          issue_1.reload
          issue_2.reload
          assert_equal 1, issue_2.position
          assert_equal 2, issue_1.position
        end
      end
    end
  end
end
