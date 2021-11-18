# frozen_string_literal: true

require "test_helper"
require_relative "people/base"

module GobiertoPeople
  class PersonProfileTest < ActionDispatch::IntegrationTest
    include People::Base

    def setup
      super
      @path = gobierto_people_person_path(person.slug)
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

    def test_person_profile
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: person.name)
        assert has_selector?(".person_charge", text: person.charge)
      end
    end

    ## TODO: fix this random failing test
    ## def test_upcoming_events_block
    ##   with_current_site(site) do
    ##     visit @path
    ##
    ##     within ".upcoming-events" do
    ##       assert has_link? "Future government event"
    ##       assert has_link? "Invited event"
    ##       assert has_link?("View all")
    ##     end
    ##   end
    ## end

    def test_latest_activity_block
      with_current_site(site) do
        visit @path

        within ".latest-activity" do
          assert has_content?("This profile has not registered any activity yet.")
        end
      end
    end

    def test_subscription_block
      skip "Subscription boxes are disabled"

      with_current_site(site) do
        visit @path

        within ".subscribable-box", match: :first do
          assert has_button?("Subscribe")
        end
      end
    end

    ## TODO: this has stopped working and maybe can be removed in the future
    ## def test_follow_person_block
    ##   with_javascript do
    ##     with_signed_in_user(user) do
    ##       visit @path
    ##
    ##       within ".slim_nav_bar" do
    ##         assert has_link? "Follow person"
    ##       end
    ##
    ##       click_on "Follow person"
    ##       assert has_link? "Person followed!"
    ##
    ##       click_on "Person followed!"
    ##       assert has_link? "Follow person"
    ##     end
    ##   end
    ## end
  end
end
