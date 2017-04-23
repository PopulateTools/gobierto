require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonEventsIndexTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_events_path(person)
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
          person.events.create! title: "Event #{i}",
            starts_at: Time.now.tomorrow + i.days, state: GobiertoPeople::PersonEvent.states["published"]
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
    end
  end
end
