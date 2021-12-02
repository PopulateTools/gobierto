# frozen_string_literal: true

require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonEventShowTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_event_path(person.slug, event.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def user
        @user ||= users(:peter)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def event
        @event ||= gobierto_calendars_events(:richard_published)
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

      def test_event_documents
        with_current_site(site) do
          visit @path

          within ".person_event-item" do
            assert has_content?("Documents")
            event.attachments.each do |attachment|
              assert has_content?(attachment.name)
            end
          end
        end
      end

      ## TODO: this has stopped working and maybe can be removed in the future
      ## def test_subscription_block
      ##   with_javascript do
      ##     with_signed_in_user(user) do
      ##       visit @path
      ##
      ##       within ".slim_nav_bar" do
      ##         assert has_link? "Follow event"
      ##       end
      ##
      ##       click_on "Follow event"
      ##       assert has_link? "Event followed!"
      ##
      ##       click_on "Event followed!"
      ##       assert has_link? "Follow event"
      ##     end
      ##   end
      ## end
    end
  end
end
