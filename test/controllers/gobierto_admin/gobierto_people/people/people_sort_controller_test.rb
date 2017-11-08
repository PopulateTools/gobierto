# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    module People
      class PeopleSortControllerTest < GobiertoControllerTest

        def admin
          @admin ||= gobierto_admin_admins(:natasha)
        end

        def person1
          @person1 ||= gobierto_people_people(:richard)
        end

        def person2
          @person2 ||= gobierto_people_people(:nelson)
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
              "0" => { id: person1.id, position: 2 },
              "1" => { id: person2.id, position: 1 }
            }
          }
        end

        def test_create
          assert_equal 1, person1.position
          assert_equal 2, person2.position

          post admin_people_people_sort_url, params: valid_sort_params
          assert_response :no_content

          person1.reload
          person2.reload
          assert_equal 1, person2.position
          assert_equal 2, person1.position
        end

      end
    end
  end
end
