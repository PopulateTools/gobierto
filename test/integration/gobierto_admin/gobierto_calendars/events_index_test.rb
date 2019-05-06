# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCalendars
    class EventsIndexTest < ActionDispatch::IntegrationTest

      def setup
        super
        @collection_path = admin_common_collection_path(collection)
      end

      def collection
        @collection ||= person.events_collection
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person_upcoming_events
        @person_upcoming_events ||= person.events.upcoming
      end

      def test_person_events_index
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @collection_path

              within "table.person-events-list tbody" do
                assert has_selector?("tr", count: person_upcoming_events.count)

                person_upcoming_events.each do |event|
                  assert has_selector?("tr#person-event-item-#{event.id}")
                end
              end
            end
          end
        end
      end

      def test_person_pending_events_index
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @collection_path
              click_link "Moderation pending"

              within "table.person-events-list tbody" do
                assert has_selector?("tr", count: person.events.pending.count)

                person.events.pending.each do |event|
                  assert has_selector?("tr#person-event-item-#{event.id}")
                end
              end
            end
          end
        end
      end

      def test_person_published_events_index
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @collection_path
              click_link "Published events"

              within "table.person-events-list tbody" do
                assert has_selector?("tr", count: person.events.published.count)

                person.events.published.each do |event|
                  assert has_selector?("tr#person-event-item-#{event.id}")

                  within "tr#person-event-item-#{event.id}" do
                    if event.published?
                      assert has_content?("Published")
                    else
                      assert has_content?("Draft")
                    end
                    assert has_link?("View event")
                  end
                end
              end
            end
          end
        end
      end

      def test_person_past_events_index
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @collection_path
              click_link "Past events"

              within "table.person-events-list tbody" do
                assert has_selector?("tr", count: person.events.past.count)

                person.events.past.each do |event|
                  assert has_selector?("tr#person-event-item-#{event.id}")
                end
              end
            end
          end
        end
      end

      def test_person_event_filtering
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @collection_path

              within ".sub_filter ul", match: :first do
                assert has_selector?(
                  ".upcoming-events-filter",
                  text: "Upcoming (#{person_upcoming_events.count})"
                )

                assert has_selector?(
                  ".pending-events-filter",
                  text: "Moderation pending (#{person.events.pending.count})"
                )

                assert has_selector?(
                  ".published-events-filter",
                  text: "Published events (#{person.events.published.count})"
                )

                assert has_selector?(
                  ".past-events-filter",
                  text: "Past events (#{person.events.past.count})"
                )
              end
            end
          end
        end
      end

      def test_preview_calendar
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit admin_common_collection_path(collection)

            assert preview_link_excludes_token?
            click_preview_link

            assert has_content? "#{person.name}'s agenda"

            person.draft!

            visit admin_common_collection_path(collection)

            assert preview_link_includes_token?
            click_preview_link

            assert has_content? "#{person.name}'s agenda"
          end
        end
      end

    end
  end
end
