# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_preview_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementPreviewTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourcePreviewTestModule

      def setup
        super
        @path = admin_people_person_statements_path(richard)
        setup_authorizable_resource_preview_test(
          gobierto_admin_admins(:steve),
          gobierto_people_person_statement_path(richard.slug, active_statement.slug),
          gobierto_people_person_statement_path(richard.slug, draft_statement.slug),
          richard
        )
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def richard
        gobierto_people_people(:richard)
      end

      def site
        @site ||= sites(:madrid)
      end

      def active_statement
        richard.statements.active.first
      end

      def draft_statement
        richard.statements.draft.first
      end

      def test_preview_active_person_active_statement
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-statement-item-#{active_statement.id}" do
              preview_link = find("a", text: "View statement")

              refute preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_statement_path(active_statement.person.slug, active_statement.slug), current_path
            assert has_selector?("h3", text: active_statement.title)
          end
        end
      end

      def test_preview_active_person_draft_statement
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-statement-item-#{draft_statement.id}" do
              preview_link = find("a", text: "View statement")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_statement_path(draft_statement.person.slug, draft_statement.slug), current_path
            assert has_selector?("h3", text: draft_statement.title)
          end
        end
      end

      def test_preview_draft_person_active_statement
        active_statement.person.draft!

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-statement-item-#{active_statement.id}" do
              preview_link = find("a", text: "View statement")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_statement_path(active_statement.person.slug, active_statement.slug), current_path
            assert has_selector?("h3", text: active_statement.title)
          end
        end
      end

      def test_preview_draft_person_draft_statement
        draft_statement.person.draft!

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-statement-item-#{draft_statement.id}" do
              preview_link = find("a", text: "View statement")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_statement_path(draft_statement.person.slug, draft_statement.slug), current_path
            assert has_selector?("h3", text: draft_statement.title)
          end
        end
      end

      def test_preview_draft_statement_if_not_admin
        with_current_site(site) do
          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_statement_path(draft_statement.person.slug, draft_statement.slug)
          end

          refute has_selector?("h3", text: draft_statement.title)

          draft_statement.person.draft!

          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_statement_path(draft_statement.person.slug, draft_statement.slug)
          end

          refute has_selector?("h3", text: draft_statement.title)
        end
      end
    end
  end
end
