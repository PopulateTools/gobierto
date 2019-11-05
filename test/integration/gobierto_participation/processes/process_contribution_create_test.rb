# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessContributionContainersCreateTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def process_path(process)
      gobierto_participation_process_path(process.slug)
    end

    def container_path
      @container_path ||= gobierto_participation_process_contribution_container_path(
        process_id: process.slug,
        id: contribution_container.slug
      )
    end

    def containers_path
      @containers_path ||= gobierto_participation_process_contribution_containers_path(
        process_id: process.slug
      )
    end

    def process
      @process ||= gobierto_participation_processes(:sport_city_process)
    end

    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
    end

    def contributions
      @contributions ||= contribution_container.contributions
    end

    def test_contribution_create
      with_javascript do
        with_signed_in_user(user, logout: false) do
          visit container_path

          assert_equal 4, contributions.size

          page.find("a", text: "Have an idea!").click

          assert has_content? "WRITE YOUR IDEA CONCISE"
          assert has_content? "DO YOU WANT TO GIVE THEM DETAILS? DEVELOP THE MAIN POINTS OF YOUR IDEA"

          fill_in :contribution_title, with: "My contribution"
          fill_in :contribution_description, with: "Contribution description"

          click_button "Create"

          sleep 1

          visit container_path

          assert has_content? "My contribution"
          assert_equal 5, contribution_container.contributions.size
        end
      end
    end

    def test_contribution_errors
      with_javascript do
        with_signed_in_user(user, logout: false) do
          visit container_path

          assert_equal contributions.size, 4

          page.find("a", text: "Have an idea!").click

          assert has_content? "WRITE YOUR IDEA CONCISE"
          assert has_content? "DO YOU WANT TO GIVE THEM DETAILS? DEVELOP THE MAIN POINTS OF YOUR IDEA"

          click_button "Create"

          assert has_alert?("Title can't be blank")
        end
      end
    end
  end
end
