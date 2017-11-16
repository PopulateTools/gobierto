# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessEventsShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_event
      @process_event ||= gobierto_calendars_events(:swimming_lessons)
    end

    def process_event_path
      @process_event_path ||= gobierto_participation_process_event_path(
        process_event.slug,
        process_id: process.slug
      )
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_event_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_event_path

        within "menu.sub_sections" do
          assert has_link? "Information"
          assert has_link? "Meetings"

          if process.polls_stage?
            assert has_link? "Polls"
          else
            refute has_link? "Polls"
          end

          assert has_link? "Contributions"
          assert has_link? "Results"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_event_path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end

        # TODO: check that these links redirect to their corresponding pages
        # applying the right scope (single process/group scope)
      end
    end

    def test_subscription_block
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user) do
            visit process_event_path

            within ".site_header" do
              assert has_link? "Follow process"
            end

            click_on "Follow process"
            assert has_link? "Process followed!"

            click_on "Process followed!"
            assert has_link? "Follow process"
          end
        end
      end
    end

    def test_process_event_show
      with_current_site(site) do
        visit process_event_path

        within ".event_wrapper" do
          assert has_content? "Swimming lessons for elders"
          assert has_content? "Instalaciones Deportivas Canal de Isabel II"
          assert has_link? "Av. de Filipinas, 54, 28003 Madrid"
        end

        assert has_content? "Agenda"
        # TODO: refute has_content? "Agenda for #{process.title}"
      end
    end
  end
end
