# frozen_string_literal: true

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

    def government_people
      @government_people ||= [
        gobierto_people_people(:richard)
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
        gobierto_calendars_events(:richard_published)
      ]
    end

    def government_member
      gobierto_people_people(:richard)
    end

    def executive_member
      gobierto_people_people(:tamara)
    end

    def government_event
      gobierto_calendars_events(:richard_published)
    end

    def government_past_event
      gobierto_calendars_events(:richard_published_past)
    end

    def executive_past_event
      gobierto_calendars_events(:tamara_published_past)
    end

    def latest_posts
      @latest_posts ||= [
        gobierto_people_person_posts(:richard_about_me),
        gobierto_people_person_posts(:richard_achievements)
      ]
    end

    def fetch_links_in_scope(scope)
      page.find(scope).all('a').map(&:text)
    end

    def test_welcome_index
      with_current_site(site) do
        visit @path

        assert has_selector?("p", text: "Home text English")
      end
    end

    def test_people_block
      with_current_site(site) do
        visit @path

        within ".people-summary" do
          within ".filter_boxed" do
            assert has_link?("Government Team")
            assert has_link?("Opposition")
            assert has_link?("Executive")
            assert has_link?("Political groups")
            refute has_link?("All")
          end

          government_people.each do |person|
            assert has_selector?(".person-item", text: person.name)
            assert has_link?(person.name)
          end

          assert has_link?("View all")
        end
      end
    end

    def test_people_summary_filters
      with_javascript do
        with_current_site(site) do
          visit @path

          links_text = fetch_links_in_scope(".people-summary")
          assert_includes links_text, government_member.name
          refute_includes links_text, executive_member.name
          assert_includes links_text, "VIEW ALL"

          links_text = fetch_links_in_scope(".events-summary")
          assert_includes links_text, government_event.title
          refute_includes links_text, government_past_event.title
          refute_includes links_text, executive_past_event.title

          click_link "Executive"

          sleep 1

          links_text = fetch_links_in_scope(".people-summary")
          refute_includes links_text, government_member.name
          assert_includes links_text, executive_member.name
          assert_includes links_text, "VIEW ALL"

          links_text = fetch_links_in_scope(".events-summary")
          assert has_content? "There are no future events. Take a look at past ones"
          refute_includes links_text, government_event.title
          assert_includes links_text, executive_past_event.title

          click_link "Opposition"

          sleep 1

          links_text = fetch_links_in_scope(".people-summary")
          refute_includes links_text, government_member.name
          refute_includes links_text, executive_member.name
          refute_includes links_text, "VIEW ALL"

          links_text = fetch_links_in_scope(".events-summary")
          assert has_content? "There are no events"
          refute_includes links_text, government_event.title
          refute_includes links_text, executive_past_event.title

          click_link "Political groups"

          assert has_content? "Officials"
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

    def test_events_summary_filters
      with_javascript do
        with_current_site(site) do
          visit @path

          links_text = fetch_links_in_scope(".events-summary")
          assert_includes links_text, government_event.title
          refute_includes links_text, government_past_event.title
          refute_includes links_text, executive_past_event.title

          click_link "Past events"

          sleep 1

          links_text = fetch_links_in_scope(".events-summary")
          refute_includes links_text, government_event.title
          assert_includes links_text, government_past_event.title
          refute_includes links_text, executive_past_event.title

          click_link "Executive"

          sleep 1

          links_text = fetch_links_in_scope(".events-summary")
          assert has_content? "There are no future events. Take a look at past ones"
          refute_includes links_text, government_event.title
          refute_includes links_text, government_past_event.title
          assert_includes links_text, executive_past_event.title
        end
      end
    end

    def test_posts_block
      with_current_site(site) do
        visit @path

        within ".posts-summary" do
          latest_posts.each do |person_post|
            assert has_selector?(".post-item", text: person_post.title)
            assert has_link?(person_post.title)
          end

          assert has_link?("View all")
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
