require "test_helper"

module GobiertoPeople
  class PersonProfileTest < ActionDispatch::IntegrationTest
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
        assert has_selector?(".intro", text: person.charge)
      end
    end

    def test_person_avatar
      with_current_site(site) do
        visit @path

        assert has_css?("img.avatar[src='#{person.avatar_url}']")
      end
    end

    def test_person_contact_methods
      with_current_site(site) do
        visit @path

        within ".contact-methods" do
          assert has_link?("@richard", href: "https://twitter.com/richard")
        end
      end
    end

    def test_person_navigation
      with_current_site(site) do
        visit @path

        within ".people-navigation" do
          assert has_link?("Profile")
          assert has_link?("Biography and CV")
          assert has_link?("Agenda")
          assert has_link?("Blog")
          assert has_link?("Goods and Activities")
        end
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

        within ".subscribable-box" do
          assert has_button?("Subscribe")
        end
      end
    end
  end
end
