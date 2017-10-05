# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_preview_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventPreviewTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourcePreviewTestModule

      def setup
        super
        @path = admin_people_person_events_path(person)
        setup_authorizable_resource_preview_test(
          gobierto_admin_admins(:steve),
          gobierto_people_person_event_path(person.slug, published_event.slug),
          gobierto_people_person_event_path(person.slug, pending_event.slug),
          person
        )
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def site
        @site ||= sites(:madrid)
      end

      def published_event
        person.events.published.first
      end

      def pending_event
        person.events.pending.first
      end

      def test_preview_active_person_published_event
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-event-item-#{published_event.id}" do
              preview_link = find("a", text: "View event")

              refute preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_event_path(person.slug, published_event.slug), current_path
            assert has_selector?("h2", text: published_event.title)
          end
        end
      end

      def test_preview_active_person_pending_event
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-event-item-#{pending_event.id}" do
              preview_link = find("a", text: "View event")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_event_path(person.slug, pending_event.slug), current_path
            assert has_selector?("h2", text: pending_event.title)
          end
        end
      end

      def test_preview_draft_person_published_event
        person.draft!

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-event-item-#{published_event.id}" do
              preview_link = find("a", text: "View event")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_event_path(person.slug, published_event.slug), current_path
            assert has_selector?("h2", text: published_event.title)
          end
        end
      end

      def test_preview_draft_person_pending_event
        person.draft!

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-event-item-#{pending_event.id}" do
              preview_link = find("a", text: "View event")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_event_path(person.slug, pending_event.slug), current_path
            assert has_selector?("h2", text: pending_event.title)
          end
        end
      end

      def test_preview_pending_event_if_not_admin
        with_current_site(site) do
          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_event_path(person.slug, pending_event.slug)
          end

          refute has_selector?("h2", text: pending_event.title)

          person.draft!

          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_event_path(person.slug, pending_event.slug)
          end

          refute has_selector?("h2", text: pending_event.title)
        end
      end
    end
  end
end
