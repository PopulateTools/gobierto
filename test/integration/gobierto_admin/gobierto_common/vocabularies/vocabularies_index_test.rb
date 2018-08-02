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
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def vocabularies
          @vocabularies ||= site.vocabularies
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
