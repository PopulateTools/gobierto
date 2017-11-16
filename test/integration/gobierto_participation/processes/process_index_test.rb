# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessIndexTest < ActionDispatch::IntegrationTest

    def setup
      super
      @path = gobierto_participation_processes_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def open_and_active_process
      @open_and_active_process ||= gobierto_participation_processes(:sport_city_process)
    end

    def open_and_active_group
      @open_and_active_group ||= gobierto_participation_processes(:green_city_group)
    end

    def draft_group
      @draft_group ||= gobierto_participation_processes(:cultural_city_group)
    end

    def future_closed_group
      @future_closed_group ||= gobierto_participation_processes(:public_debates_group_future)
    end

    def past_closed_group
      @past_closed_group ||= gobierto_participation_processes(:dance_studio_group_ended)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Processes"
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within "menu.sub_sections" do
          assert has_link? "About"
          assert has_link? "Issues"
          assert has_link? "Processes"
          assert has_link? "Ask"
          assert has_link? "Ideas"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit @path

        within "menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end

        # TODO: check that these links redirect to their corresponding pages
        # applying the right scope (all processes/groups scope)
      end
    end

    def test_processes_index
      with_current_site(site) do
        visit @path

        assert has_link?(open_and_active_process.title)
        assert has_link?(open_and_active_group.title)
        refute has_link?(draft_group.title)
        assert has_link?(future_closed_group.title)
        assert has_link?(past_closed_group.title)
      end
    end

  end
end
