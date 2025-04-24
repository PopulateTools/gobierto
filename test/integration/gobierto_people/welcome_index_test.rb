# frozen_string_literal: true

require "test_helper"
require_relative "navigation_items"

module GobiertoPeople
  class WelcomeIndexTest < ActionDispatch::IntegrationTest
    include NavigationItems

    FAR_FUTURE = 10.years.from_now

    def setup
      super
      @path = root_path
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
        gobierto_common_terms(:marvel_term),
        gobierto_common_terms(:dc_term)
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

    def opposition_member
      gobierto_people_people(:neil)
    end

    def government_event
      gobierto_calendars_events(:richard_published)
    end

    def opposition_event
      gobierto_calendars_events(:neil_published)
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

    def test_welcome_index_redirect
      with_current_site(site) do
        visit gobierto_people_root_path

        assert_redirected_to root_path
      end
    end

    def test_welcome_index
      with_current_site(site) do
        visit root_path

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
            assert has_no_link?("All")
          end

          government_people.each do |person|
            assert has_selector?(".person-item", text: person.name)
            assert has_link?(person.name)
          end

          assert has_link?("View all")
        end
      end
    end

    def test_blog_block
      with_current_site(site) do
        visit @path

        within '.container' do
          assert has_content? 'Blogs'
        end

        PersonPost.all.destroy_all
        visit @path

        within '.container' do
          assert has_no_content? 'Blogs'
        end
      end
    end

    def test_people_summary_filters
      with_javascript do
        with_current_site(site) do
          visit @path

          within ".people-summary" do
            assert has_link? government_member.name
            assert has_no_link? opposition_member.name
            assert has_no_link? executive_member.name
            assert has_link?("View all")
          end

          within ".events-summary" do
            assert has_link? government_event.title
            assert has_no_link? government_past_event.title
            assert has_no_link? opposition_event.title
            assert has_no_link? executive_past_event.title
          end

          # simulate all events have passed
          Timecop.freeze(FAR_FUTURE) do
            click_link "Executive"

            within ".people-summary" do
              assert has_no_link? government_member.name
              assert has_no_link? opposition_member.name
              assert has_link? executive_member.name
              assert has_link?("View all")
            end

            within ".events-summary" do
              assert has_content? "There are no future events. Take a look at past ones"
              assert has_no_link? government_event.title
              assert has_no_link? government_past_event.title
              assert has_no_link? opposition_event.title
              assert has_link? executive_past_event.title
            end
          end

          click_link "Opposition"

          sleep 1

          within ".people-summary" do
            assert has_no_link? government_member.name
            assert has_link? opposition_member.name
            assert has_no_link? executive_member.name
            assert has_link?("View all")
          end

          within ".events-summary" do
            assert has_no_link? government_event.title
            assert has_no_link? government_past_event.title
            assert has_link? opposition_event.title
            assert has_no_link? executive_past_event.title
          end
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

          within ".events-summary" do
            assert has_content? government_event.title
            assert has_no_content? government_past_event.title
            assert has_no_content? executive_past_event.title
          end

          click_link "Past events"

          within ".events-summary" do
            assert has_no_content? government_event.title
            assert has_content? government_past_event.title
            assert has_no_content? executive_past_event.title
          end

          # simulate all events have passed
          Timecop.freeze(FAR_FUTURE) do
            click_link "Executive"

            within ".events-summary" do
              assert has_content? "There are no future events. Take a look at past ones"
              assert has_no_content? government_event.title
              assert has_no_content? government_past_event.title
              assert has_content? executive_past_event.title
            end
          end

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
      skip "Subscription boxes are disabled"

      with_current_site(site) do
        visit @path

        within ".subscribable-box", match: :first do
          assert has_button?("Subscribe")
        end
      end
    end
  end
end
