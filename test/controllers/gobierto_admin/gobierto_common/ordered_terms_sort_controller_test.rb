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

        def node
          @node = gobierto_plans_nodes(:scholarships_kindergartens)
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
              "0" => { id: mammal.id, position: 0, class: "GobiertoCommon::Term" },
              "1" => { id: bird.id, position: 1, class: "GobiertoCommon::Term" },
              "2" => { id: cat.id, position: 0, class: "GobiertoCommon::Term" },
              "3" => { id: dog.id, position: 1, class: "GobiertoCommon::Term" },
              "4" => { id: swift.id, position: 2, class: "GobiertoCommon::Term" },
              "5" => { id: pigeon.id, position: 0, class: "GobiertoCommon::Term" },
              "6" => { id: node.id, position: 33, class: "GobiertoPlans::Node" }
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
            node.reload

            assert_equal 0, cat.position
            assert_equal 1, dog.position
            assert_equal 2, swift.position
            assert_equal 0, pigeon.position
            assert_equal 33, node.position
          end
        end
      end
    end
  end
end
