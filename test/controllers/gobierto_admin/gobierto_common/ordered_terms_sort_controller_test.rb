# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Configuration
      class OrderedTermsSortControllerTest < GobiertoControllerTest
        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        # Animals vocabulary (fixtures positions):
        # - mammal
        #   - dog
        #   - cat
        # - bird
        #   - swift
        #   - pigeon

        def mammal
          @mammal ||= gobierto_common_terms(:mammal)
        end

        def bird
          @bird ||= gobierto_common_terms(:bird)
        end

        def dog
          @dog ||= gobierto_common_terms(:dog)
        end

        def cat
          @cat ||= gobierto_common_terms(:cat)
        end

        def pigeon
          @pigeon ||= gobierto_common_terms(:pigeon)
        end

        def swift
          @swift ||= gobierto_common_terms(:swift)
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
              "0" => [ mammal.id, bird.id ],
              mammal.id.to_s => [ cat.id, dog.id, swift.id],
              bird.id.to_s => [ pigeon.id ]
            }
          }
        end

        def valid_sort_params_update_parent
          {
            positions: {
              "0" => [ mammal.id, swift.id, bird.id ],
              mammal.id.to_s => [ cat.id, dog.id ],
              bird.id.to_s => [ pigeon.id ]
            }
          }
        end

        # Test new positions
        # - mammal
        #   - cat
        #   - dog
        #   - swift
        # - bird
        #   - pigeon
        def test_order_update
          with_current_site(site) do
            assert_equal 0, dog.position
            assert_equal 1, cat.position

            post admin_common_vocabulary_terms_sort_url(vocabulary), params: valid_sort_params
            assert_response :no_content

            cat.reload
            dog.reload
            swift.reload
            pigeon.reload

            assert_equal 0, cat.position
            assert_equal 1, dog.position
            assert_equal 2, swift.position
            assert_equal mammal, swift.parent_term
            assert_equal 0, pigeon.position
          end
        end

        # Test new positions
        # - mammal
        #   - cat
        #   - dog
        # - swift
        # - bird
        #   - pigeon
        def test_order_update_moving_element_to_other_parent
          with_current_site(site) do
            assert_equal 0, dog.position
            assert_equal 1, cat.position

            post admin_common_vocabulary_terms_sort_url(vocabulary), params: valid_sort_params_update_parent
            assert_response :no_content

            cat.reload
            dog.reload
            swift.reload
            pigeon.reload

            assert_equal 0, cat.position
            assert_equal 1, dog.position
            assert_equal 1, swift.position
            assert_nil swift.parent_term
            assert_equal 0, pigeon.position
          end
        end
      end
    end
  end
end
