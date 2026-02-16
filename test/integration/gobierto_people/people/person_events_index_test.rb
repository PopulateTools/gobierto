# frozen_string_literal: true

require "test_helper"
require_relative "base_index"
require "support/event_helpers"

module GobiertoPeople
  module People
    class PersonEventsIndexTest < ActionDispatch::IntegrationTest
      include BaseIndex
      include ::EventHelpers

      def setup
        super
        @path = gobierto_people_person_events_path(richard.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def richard
        @richard ||= gobierto_people_people(:richard)
      end
      alias_method :person, :richard

      def nelson
        @nelson ||= gobierto_people_people(:nelson)
      end

      def upcoming_events
        @upcoming_events ||= [
          gobierto_calendars_events(:richard_published)
        ]
      end

      def test_person_events_index
        with_current_site(site) do
          visit @path

          assert has_selector?("h2", text: "#{richard.name}'s agenda")
        end
      end

      def test_events_summary
        with_javascript do
          with_current_site(site) do
            visit @path

            click_button 'List'

            within ".events-summary" do
              assert has_content?("Agenda")
              assert has_no_link?("View more")
              assert has_link?("Past events")

              upcoming_events.each do |event|
                assert has_selector?(".person_event-item", text: event.title)
                assert has_link?(event.title)
              end
            end
          end
        end
      end

      def test_events_summary_upcoming_and_past_filters
        richard.events.destroy_all
        far_past_event = create_event(title: "Richard far past event", starts_at: :far_past)
        past_event = create_event(title: "Richard past event", starts_at: :past)
        pending_past_event = create_event(title: "Richard past pending event", starts_at: :past, state: :pending)
        future_event = create_event(title: "Richard future event", starts_at: :future)
        pending_future_event = create_event(title: "Richard future pending event", starts_at: :future, state: :pending)
        far_future_event = create_event(title: "Richard far future event", starts_at: :far_future)

        with_javascript do
          with_current_site(site) do
            visit @path

            click_button "List"

            within ".events-summary" do
              assert has_no_content?(far_past_event.title)
              assert has_no_content?(past_event.title)
              assert has_no_content?(pending_future_event.title)
              assert ordered_elements(page, [future_event.title, far_future_event.title])
            end

            click_link "Past events"

            within ".events-summary" do
              assert has_no_content?(future_event.title)
              assert has_no_content?(far_future_event.title)
              assert has_no_content?(pending_past_event.title)
              assert ordered_elements(page, [past_event.title, far_past_event.title])
            end
          end
        end
      end

      def test_person_events_present_in_other_agendas
        attributes = {
          starts_at: Time.now.tomorrow,
          title: "Duplicated event",
          external_id: "duplicated-event"
        }
        richard_event = create_event(attributes.merge(person: richard))
        richard_event.attendees.create(person: nelson)
        nelson_event = create_event(attributes.merge(person: nelson))
        nelson_event.attendees.create(person: richard)

        with(site: site, js: true) do
          visit @path

          click_button "List"

          assert has_content? richard_event.title
        end
      end

      def test_calendar_navigation_arrows
        year = Date.today.year
        past_event = create_event(starts_at: "#{year}-02-15", person: richard)
        present_event = create_event(starts_at: "#{year}-03-15", person: richard)
        future_event = create_event(starts_at: "#{year}-04-15", person: richard)

        Timecop.freeze(Time.zone.parse("#{year}-03-15")) do
          with_current_site(site) do
            visit @path

            within ".calendar-component" do
              assert has_link?(present_event.starts_at.day)
            end

            click_link "next-month-link"

            within ".calendar-component" do
              assert has_link?(future_event.starts_at.day)
            end

            visit @path

            click_link "previous-month-link"

            within ".calendar-component" do
              assert has_link?(past_event.starts_at.day)
            end
          end
        end
      end

      def test_filter_events_by_calendar_date_link
        richard.events.destroy_all

        freeze_date = Time.zone.parse("#{Date.today.year}-04-15 6:00")
        yesterday = freeze_date - 1.day

        yesterday_early_event = create_event(title: "Yesterday early event", starts_at: yesterday.change(hour: 7))
        yesterday_late_event = create_event(title: "Yesterday late event", starts_at: yesterday.change(hour: 20))
        tomorrow_event = create_event(title: "Tomorrow event", starts_at: freeze_date + 1.day)

        midday_events = []
        10.times do |index|
          midday_events << create_event(title: "Yesterday midday event #{index}", starts_at: yesterday.change(hour: 14, min: index))
        end

        Timecop.freeze(freeze_date) do
          with_javascript do
            with_current_site(site) do
              visit @path

              within ".calendar-component" do
                click_link yesterday_early_event.starts_at.day
              end

              assert has_content? "Displaying events of #{yesterday_early_event.starts_at.strftime("%b %d %Y")}"
            end
          end
        end
      end

    end
  end
end
