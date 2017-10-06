# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessContributionContainersShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:dennis)
    end

    def process
      @process ||= gobierto_participation_processes(:sport_city_process)
    end

    def contribution_container
      @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
    end

    def container_path
      @container_path ||= gobierto_participation_process_process_contribution_container_path(
        process_id: process.slug,
        id: contribution_container.slug
      )
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

    def test_breadcrumb_items
      with_current_site(site) do
        visit container_path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit container_path

        within "menu.sub_sections" do
          assert has_link? "Information"
          assert has_link? "Meetings"
          assert has_link? "Polls"
          assert has_link? "Contributions"
          assert has_link? "Results"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit container_path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Diary"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit container_path

        within ".site_header" do
          assert has_content? "Follow this process"
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

          page.find('[data-url="/participacion/procesos/ciudad-deportiva/contribution_containers/children-contributions/contributions/carril-bici"]', visible: false).trigger("click")
          assert has_content? "Carril bici hasta el Juan Carlos I"
        end
      end
    end

    def test_vote_contribution
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user) do
            visit container_path

            page.find('[data-url="/participacion/procesos/ciudad-deportiva/contribution_containers/children-contributions/contributions/carril-bici"]', visible: false).trigger("click")
            assert has_content? "Carril bici para que los niños puedan llegar al parque desde cualquier punto de Barajas."
            assert has_content? "It values the idea"
            page.find("a.action_button.love").trigger("click")
            assert has_content? "It enchants to me"
          end
        end
      end
    end

    def test_contribution_commments
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user) do
            visit container_path

            page.find('[data-url="/participacion/procesos/ciudad-deportiva/contribution_containers/children-contributions/contributions/carril-bici"]', visible: false).trigger("click")
            assert has_content? "Carril bici para que los niños puedan llegar al parque desde cualquier punto de Barajas."

            within "div.comments_container" do
              contribution_comments.each do |comment|
                assert has_selector?("div.comment div")
              end
            end
          end
        end
      end
    end
  end
end
