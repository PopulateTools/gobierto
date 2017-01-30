require "test_helper"

module GobiertoPeople
  class WelcomeIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_root_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def recent_people
      @recent_people ||= [
        gobierto_people_people(:richard),
        gobierto_people_people(:tamara)
      ]
    end

    def political_groups
      @political_groups ||= [
        gobierto_people_political_groups(:marvel),
        gobierto_people_political_groups(:dc)
      ]
    end

    def upcoming_events
      @upcoming_events ||= [
        gobierto_people_person_events(:richard_published)
      ]
    end

    def latest_posts
      @latest_posts ||= [
        gobierto_people_person_posts(:richard_about_me),
        gobierto_people_person_posts(:richard_achievements)
      ]
    end

    def test_welcome_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Know the people who work to make your city a better place to live.")
      end
    end

    def test_people_block
      with_current_site(site) do
        visit @path

        within ".people-summary" do
          within ".people-filter" do
            assert has_link?("Government Team")
            assert has_link?("Opposition")
            assert has_link?("Executive")
            assert has_link?("All")

            assert has_content?("Political groups")

            political_groups.each do |political_group|
              assert has_link?(political_group.name)
            end
          end

          recent_people.each do |person|
            assert has_selector?(".person-item", text: person.name)
            assert has_link?(person.name)
          end

          assert has_link?("View all")
        end
      end
    end

    def test_events_block
      with_current_site(site) do
        visit @path

        within ".events-summary" do
          assert has_content?("Agenda")
          assert has_link?("Past events")

          upcoming_events.each do |event|
            assert has_selector?(".person_event-item", text: event.title)
            assert has_link?(event.title)
          end

          assert has_link?("View all")
        end
      end
    end

    def test_site_references_block
      with_current_site(site) do
        visit @path

        within "ul.site-references" do
          assert has_selector?("li", text: "Salaries and retributions")
          assert has_link?("Salaries and retributions")

          assert has_selector?("li", text: "Gifts")
          assert has_link?("Gifts")

          assert has_selector?("li", text: "Travels")
          assert has_link?("Travels")
        end
      end
    end

    def test_posts_block
      with_current_site(site) do
        visit @path

        within ".posts-summary" do
          latest_posts.each do |person_post|
            assert has_selector?(".person_post-item", text: person_post.title)
            assert has_link?(person_post.title)
          end

          assert has_link?("View all")
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
