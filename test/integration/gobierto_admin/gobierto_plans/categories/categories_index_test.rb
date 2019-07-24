# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoPlans
    module Categories
      class CategoriesIndexTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern
        include ::GobiertoAdmin::PreviewableItemTestModule

        def setup
          super
          @path = admin_plans_plan_categories_path(plan)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def plan
          @plan ||= gobierto_plans_plans(:strategic_plan)
        end

        def preview_test_conf
          {
            item_admin_path: @path,
            item_public_url: gobierto_plans_plan_url(plan.plan_type.slug, plan.year, host: site.domain),
            publish_proc: -> { plan.published! },
            unpublish_proc: -> { plan.draft! }
          }
        end

        def test_admin_categories_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "div.pure-u-md-1-3", text: "Global progress" do
                within "div.metric_value" do
                  assert has_content? "25%"
                end
              end
            end
          end
        end

        def test_index_without_categories_vocabulary
          plan.update_attribute(:vocabulary_id, nil)
          with(site: site, admin: admin, js: false) do
            visit @path

            within "div.tabs" do
              assert has_no_content? "Categories"
              within "li.active" do
                assert has_content? "Configuration"
              end
            end

          end
        end

        def test_regular_admin_index_without_categories_vocabulary
          plan.update_attribute(:vocabulary_id, nil)
          with(site: site, admin: regular_admin) do
            visit @path

            assert has_content? "You are not authorized to perform this action"
          end
        end

      end
    end
  end
end
