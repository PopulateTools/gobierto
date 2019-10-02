# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    module Vocabularies
      class VocabulariesIndexTest < ActionDispatch::IntegrationTest

        def setup
          super
          @path = admin_common_vocabularies_path
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def vocabularies
          @vocabularies ||= site.vocabularies
        end

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal edit_admin_admin_settings_path, current_path
            end
          end
        end

        def test_vocabularies_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table tbody" do
                assert has_selector?("tr", count: vocabularies.count)

                vocabularies.each do |vocabulary|
                  assert has_selector?("tr#vocabulary-item-#{vocabulary.id}")

                  within "tr#vocabulary-item-#{vocabulary.id}" do
                    assert has_link?(vocabulary.name.to_s)
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
