require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonEventShowTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_event_path(person, event)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def event
        @event ||= gobierto_people_person_events(:richard_published)
      end

      def test_person_event_show
        with_current_site(site) do
          visit @path

          assert has_content?("#{person.name}'s agenda")
          assert has_content?(event.title)
        end
      end

      def test_event_attendees
        with_current_site(site) do
          visit @path

          within ".event-attendees" do
            event.attendees.each do |attendee|
              if attendee.person.present?
                assert has_link?(attendee.person.name)
              else
                assert has_content?(attendee.name)
              end
            end
          end
        end
      end

      def test_event_locations
        with_current_site(site) do
          visit @path

          within ".event-locations" do
            event.locations.each do |location|
              assert has_link?(location.name)
              assert has_content?(location.address)
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
    end
  end
end
