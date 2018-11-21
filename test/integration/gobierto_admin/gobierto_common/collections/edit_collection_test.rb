# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module Collections
      class ShowCollectionTest < ActionDispatch::IntegrationTest

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def collection
          @collection ||= gobierto_common_collections(:bowling_group_very_active_documents)
        end

        def collection_of_archived_container
          @collection_of_archived_container ||= gobierto_common_collections(:group_archived_documents)
        end

        def archived_container
          @archived_container ||= gobierto_participation_processes(:group_archived)
        end

        def test_edit_collection
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_common_collection_path(collection)

              assert has_content?(collection.container.title)
            end
          end
        end

        def test_edit_collection_of_archived_container
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_common_collection_path(collection_of_archived_container)

              assert has_content?("The resource the collection belongs to couldn't be found")
              assert has_no_content?(archived_container.title)
            end
          end
        end

      end
    end
  end
end
