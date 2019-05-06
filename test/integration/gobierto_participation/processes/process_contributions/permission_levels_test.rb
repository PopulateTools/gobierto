# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  module Processes
    module ProcessContributions
      class PermissionLevelsTest < ActionDispatch::IntegrationTest
        def site
          @site ||= sites(:madrid)
        end

        def registered_level_user
          @registered_level_user ||= users(:janet)
        end

        def verified_level_user
          @verified_level_user ||= users(:peter)
        end

        def registered_level_contribution_container
          @registered_level_contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
        end

        def verified_level_contribution_container
          @verified_level_contribution_container ||= gobierto_participation_contribution_containers(:neighbors_contributions)
        end

        def container_path(container)
          gobierto_participation_process_contribution_container_path(container.process.slug, container.slug)
        end

        def new_participation_path(container)
          new_gobierto_participation_process_contribution_container_contribution_path(container.process.slug, container.slug)
        end

        def with_js_session_of_user(user)
          with_javascript do
            visit root_path
            sign_out_user unless has_content? "Sign in"
            with_signed_in_user(user) do
              yield
            end
          end
        end

        def test_not_registered_user_contributions
          sign_out_user
          with_current_site(site) do
            visit container_path registered_level_contribution_container
            assert has_no_link? 'Have an idea!', href: new_participation_path(registered_level_contribution_container)

            visit container_path verified_level_contribution_container
            assert has_no_link? 'Have an idea!', href: new_participation_path(verified_level_contribution_container)
          end
        end

        def test_registered_level_user_contributions_registered_level
          with_js_session_of_user(registered_level_user) do
            visit container_path registered_level_contribution_container
            assert has_link? 'Have an idea!', href: new_participation_path(registered_level_contribution_container)
            page.find("a", text: "Have an idea!").trigger("click")
            assert page.has_content? "WRITE YOUR IDEA CONCISE"
          end
        end

        def test_registered_level_user_contributions_verified_level
          with_js_session_of_user(registered_level_user) do
            visit container_path verified_level_contribution_container
            assert has_link? 'Have an idea!', href: new_participation_path(verified_level_contribution_container)
            page.find("a", text: "Have an idea!").trigger("click")
            assert has_no_content? "WRITE YOUR IDEA CONCISE"
          end
        end

        def test_verified_level_user_contributions_registered_level
          with_js_session_of_user(verified_level_user) do
            visit container_path registered_level_contribution_container
            assert has_link? 'Have an idea!', href: new_participation_path(registered_level_contribution_container)
            page.find("a", text: "Have an idea!").trigger("click")
            assert page.has_content? "WRITE YOUR IDEA CONCISE"
          end
        end

        def test_verified_level_user_contributions_verified_level
          with_js_session_of_user(verified_level_user) do
            visit container_path verified_level_contribution_container
            assert has_link? 'Have an idea!', href: new_participation_path(verified_level_contribution_container)
            page.find("a", text: "Have an idea!").trigger("click")
            assert page.has_content? "WRITE YOUR IDEA CONCISE"
          end
        end
      end
    end
  end
end
