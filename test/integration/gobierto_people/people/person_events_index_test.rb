require "test_helper"
require_relative "base"
require "support/person_event_helpers"

module GobiertoPeople
  module People
    class PersonEventsIndexTest < ActionDispatch::IntegrationTest
      include Base
      include ::PersonEventHelpers

      def setup
        super
        @path = gobierto_people_person_events_path(person.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def upcoming_events
        @upcoming_events ||= [
          gobierto_people_person_events(:richard_published)
        ]
      end

      def test_person_events_index
        with_current_site(site) do
          visit @path

          assert has_selector?("h2", text: "#{person.name}'s agenda")
        end
      end

      def test_events_summary
        with_current_site(site) do
          visit @path

          within ".events-summary" do
            assert has_content?("Agenda")
            refute has_link?("View more")
            assert has_link?("Past events")

            upcoming_events.each do |event|
              assert has_selector?(".person_event-item", text: event.title)
              assert has_link?(event.title)
            end
          end
        end
      end

      def test_events_summary_upcoming_and_past_filters
        past_event    = create_event(title: "Past event title", starts_at: "2014-02-15", person: person)
        future_event  = create_event(title: "Future event title", starts_at: "2014-04-15", person: person)

        Timecop.freeze(Time.zone.parse("2014-03-15")) do

          with_current_site(site) do
            visit gobierto_people_person_events_path(person.slug)

            within ".events-summary" do
              refute has_content?(past_event.title)
              assert has_content?(future_event.title)
            end

            click_link "Past events"

            within ".events-summary" do
              assert has_content?(past_event.title)
              refute has_content?(future_event.title)
            end
          end
        end
      end

      def test_subscription_block
        with_current_site(site) do
          visit @path

          within ".subscribable-box", match: :first do
            assert has_button?("Subscribe")
          end
        end
      end

      def test_person_events_index_pagination
        10.times do |i|
          person.events.create!(
            title: "Event #{i}",
            site: person.site,
            starts_at: Time.now.tomorrow + i.days,
            ends_at:   Time.now.tomorrow + i.days + 1.hour,
            state: GobiertoPeople::PersonEvent.states["published"]
          )
        end

        with_current_site(site) do
          visit @path

          assert has_link?("View more")
          refute has_link?("Event 8")
          click_link "View more"

          assert has_link?("Event 8")
          refute has_link?("View more")
        end
      end

      def test_calendar_navigation_arrows
        past_event    = create_event(starts_at: "2014-02-15", person: person)
        present_event = create_event(starts_at: "2014-03-15", person: person)
        future_event  = create_event(starts_at: "2014-04-15", person: person)

        Timecop.freeze(Time.zone.parse("2014-03-15")) do

          with_current_site(site) do
            visit gobierto_people_person_events_path(person.slug)

            within ".calendar-component" do
              assert has_link?(present_event.starts_at.day)
            end

            click_link "next-month-link"

            within ".calendar-component" do
              assert has_link?(future_event.starts_at.day)
            end

            visit gobierto_people_person_events_path(person.slug)

            click_link "previous-month-link"

            within ".calendar-component" do
              assert has_link?(past_event.starts_at.day)
            end
          end

        end
      end

      def test_filter_events_by_calendar_date_link
        past_event    = create_event(title: "Past event title", starts_at: "2014-03-10 11:00", person: person)
        future_event  = create_event(title: "Future event title", starts_at: "2014-03-20 11:00", person: person)

        Timecop.freeze(Time.zone.parse("2014-03-15")) do

          with_current_site(site) do
            visit gobierto_people_person_events_path(person.slug)

            within ".events-summary" do
              refute has_content?(past_event.title)
              assert has_content?(future_event.title)
            end

            within ".calendar-component" do
              click_link past_event.starts_at.day
            end

            assert has_content? "Displaying events of #{past_event.starts_at.strftime("%b %d %Y")}"

            within ".events-summary" do
              assert has_content?(past_event.title)
              refute has_content?(future_event.title)
            end
          end
        end
      end

    end
  end
end
