# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_preview_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPreviewTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourcePreviewTestModule

      def setup
        super
        @path = admin_people_people_path
        setup_authorizable_resource_preview_test(
          gobierto_admin_admins(:steve),
          gobierto_people_person_path(published_person.slug),
          gobierto_people_person_path(draft_person.slug)
        )
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def published_person
        @published_person ||= site.people.active.first
      end

      def draft_person
        @draft_person ||= site.people.draft.first
      end

      def test_preview_published_person
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-item-#{published_person.id}" do
              preview_link = find("a", text: "View person")

              refute preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_path(published_person.slug), current_path
            assert has_selector?("h2", text: published_person.name)
          end
        end
      end

      def test_preview_draft_person_as_admin
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-item-#{draft_person.id}" do
              preview_link = find("a", text: "View person")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_path(draft_person.slug), current_path
            assert has_selector?("h2", text: draft_person.name)
          end
        end
      end

      def test_preview_draft_page_if_not_admin
        with_current_site(site) do
          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_path(draft_person.slug)
          end

          # assert_response :not_found
          refute has_selector?("h2", text: draft_person.name)
        end
      end
    end
  end
end
