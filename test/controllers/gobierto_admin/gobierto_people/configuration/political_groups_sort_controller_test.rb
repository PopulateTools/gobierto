# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    module Configuration
      class PoliticalGroupsSortControllerTest < GobiertoControllerTest
        def admin
          @admin ||= gobierto_admin_admins(:natasha)
        end

        def political_group_1
          @political_group_1 ||= gobierto_people_political_groups(:marvel)
        end

        def political_group_2
          @political_group_2 ||= gobierto_people_political_groups(:dc)
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
              "0" => { id: political_group_1.id, position: 2 },
              "1" => { id: political_group_2.id, position: 1 }
            }
          }
        end

        def test_create
          assert_equal 1, political_group_1.position
          assert_equal 2, political_group_2.position

          post admin_people_configuration_political_groups_sort_url, params: valid_sort_params
          assert_response :no_content

          political_group_1.reload
          political_group_2.reload
          assert_equal 1, political_group_2.position
          assert_equal 2, political_group_1.position
        end
      end
    end
  end
end
