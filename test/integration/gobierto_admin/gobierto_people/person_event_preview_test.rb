require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventPreviewTest < ActionDispatch::IntegrationTest

      def setup
        super
        @path = admin_people_person_events_path(richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def richard
        @person ||= gobierto_people_people(:richard)
      end

      def site
        @site ||= sites(:madrid)
      end

      def published_event
        @published_event ||= richard.events.published.first
      end

      def pending_event
        @pending_event ||= richard.events.pending.first
      end

      def test_preview_published_event
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-event-item-#{published_event.id}" do

              preview_link = find("a", text: "View event")

              refute preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_event_path(published_event.person.slug, published_event.slug), current_path
            assert has_selector?("h2", text: published_event.title)
          end
        end
      end

      def test_preview_pending_event_as_admin
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-event-item-#{pending_event.id}" do
              preview_link = find("a", text: "View event")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_event_path(pending_event.person.slug, pending_event.slug), current_path
            assert has_selector?("h2", text: pending_event.title)
          end
        end
      end

      def test_preview_pending_event_if_not_admin
        with_current_site(site) do

          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_event_path(pending_event.person.slug, pending_event.slug)
          end

          # assert_response :not_found
          refute has_selector?("h2", text: pending_event.title)
        end
      end

    end
  end
end
