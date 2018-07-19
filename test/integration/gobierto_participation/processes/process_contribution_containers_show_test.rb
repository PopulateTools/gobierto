# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessContributionContainersShowTest < ActionDispatch::IntegrationTest
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

    def past_contribution_container_path
      @container_path ||= gobierto_participation_process_contribution_container_path(
        process_id: gobierto_participation_processes(:bowling_group_very_active).slug,
        id: past_contribution_container.slug
      )
    end

    def contribution_path
      @contribution_path ||= gobierto_participation_process_contribution_container_path(
        process_id: process.slug,
        id: contribution_container.slug,
        anchor: contribution.slug
      )
    end

    def contribution_containers_path
      @contribution_containers_path ||= gobierto_participation_process_contribution_containers_path(
        process_id: process.slug,
      )
    end

    def process
      @process ||= gobierto_participation_processes(:sport_city_process)
    end

    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
    end

    def past_contribution_container
      @past_contribution_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_past)
    end

    def contributions
      @contributions ||= contribution_container.contributions
    end

    def contributions_best_ratings
      @contributions_best_ratings ||= contribution_container.contributions.loved
    end

    def contributions_worst_ratings
      @contributions_worst_ratings ||= contribution_container.contributions.hated
    end

    def contributions_recent
      @contributions_recent ||= contribution_container.contributions.created_at_last_week
    end

    def contribution
      @contribution ||= gobierto_participation_contributions(:park)
    end

    def contribution_comments
      @contribution_comments ||= contribution.comments
    end

    def test_contribution_path
      with_javascript do
        with_current_site(site) do
          visit contribution_path
          assert has_content? "Carril bici para que los niños puedan llegar al parque desde cualquier punto de Barajas."
        end
      end
    end

    def test_all_contributions_show
      with_javascript do
        with_current_site(site) do
          visit container_path

          assert_equal contributions.size, all(".card").size
          within ".contributions_content" do
            assert has_content? "Cine de verano en el Juan Carlos I"
            assert has_content? "Carril bici hasta el Juan Carlos I"
            assert has_content? "Más actividades en las fiestas de Barajas"
            assert has_content? "Parques infantiles de calidad consuelo acolchado"
          end
        end
      end
    end

    def test_best_ratings_contributions_show
      with_javascript do
        with_current_site(site) do
          visit container_path

          page.find("[data-filter=best_ratings]", visible: false).trigger("click")

          assert_equal contributions_best_ratings.size, all(".card").size
          within ".contributions_content" do
            assert has_content? "Carril bici hasta el Juan Carlos I"
            assert has_content? "Más actividades en las fiestas de Barajas"
          end
        end
      end
    end

    def test_worst_ratings_contributions_show
      with_javascript do
        with_current_site(site) do
          visit container_path

          page.find("[data-filter=worst_ratings]", visible: false).trigger("click")

          assert_equal contributions_worst_ratings.size, all(".card").size
        end
      end
    end

    def test_recent_contributions_show
      with_javascript do
        with_current_site(site) do
          visit container_path

          page.find("[data-filter=recent]", visible: false).trigger("click")

          assert_equal contributions_recent.size, all(".card").size

          within ".contributions_content" do
            assert has_content? "Parques infantiles de calidad consuelo acolchado"
          end
        end
      end
    end

    def test_contribution_show
      with_javascript do
        with_current_site(site) do
          visit container_path

          page.find('[data-url="/participacion/p/ciudad-deportiva/aportaciones/children-contributions/contributions/carril-bici"]', visible: false).trigger("click")
          assert has_content? "Carril bici hasta el Juan Carlos I"
        end
      end
    end

    def test_vote_contribution
      with_javascript do
        with_signed_in_user(user) do
          visit container_path
          assert has_content? "What activities for children we can start up?"

          page.find('[data-url="/participacion/p/ciudad-deportiva/aportaciones/children-contributions/contributions/carril-bici"]', visible: false).trigger("click")
          assert has_content? "Carril bici para que los niños puedan llegar al parque desde cualquier punto de Barajas."
          assert has_content? "Rate the idea"
          page.find("a.action_button.love").trigger("click")
          assert has_content? "It enchants to me"

          find(".modal_like_control a", visible: false).click

          assert_equal contribution_containers_path, current_path
        end
      end
    end

    def test_contribution_commments
      with_javascript do
        with_signed_in_user(user) do
          visit container_path

          page.find('[data-url="/participacion/p/ciudad-deportiva/aportaciones/children-contributions/contributions/carril-bici"]', visible: false).trigger("click")
          assert has_content? "Carril bici para que los niños puedan llegar al parque desde cualquier punto de Barajas."

          within "div.comments_container" do
            contribution_comments.each do |comment|
              assert has_selector?("div.comment div")
            end
          end

          find(".modal_like_control a", visible: false).click

          assert_equal contribution_containers_path, current_path
        end
      end
    end

    def test_cant_vote_contributions_on_closed_contribution_container
      with_javascript do
        with_signed_in_user(user) do
          visit past_contribution_container_path

          assert has_content? 'This container has already finished'

          # ensure button to create contribution is disabled
          assert find('a.js-disabled.disabled-grayed.disabled-cursor').present?

          page.find('[data-url="/participacion/p/grupo-de-petanca/aportaciones/lawn-bowling-past-contributions/contributions/contribution-on-closed-container"]', visible: false).trigger("click")

          sleep 1

          # ensure buttons to rate contributions are disabled
          assert_equal 4, all('a.action_button.js-disabled.disabled-cursor').size
        end
      end
    end
  end
end
