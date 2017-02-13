require "test_helper"
require_relative "people/base"

module GobiertoPeople
  class PersonProfileTest < ActionDispatch::IntegrationTest
    include People::Base

    def setup
      super
      @path = gobierto_people_person_path(person)
    end

    def site
      @site ||= sites(:madrid)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def test_person_profile
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: person.name)
        assert has_selector?(".person_charge", text: person.charge)
      end
    end

    def test_upcoming_events_block
      with_current_site(site) do
        visit @path

        within ".upcoming-events" do
          person.events.upcoming.each do |person_event|
            assert has_link?(person_event.title)
          end

          assert has_link?("View all")
        end
      end
    end

    def test_latest_activity_block
      with_current_site(site) do
        visit @path

        within ".latest-activity" do
          assert has_content?("This profile has not registered any activity yet.")
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
