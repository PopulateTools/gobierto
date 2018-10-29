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
      @open_and_active_group ||= gobierto_participation_processes(:green_city_group_active_empty)
    end
    alias group_without_contributions open_and_active_group

    def draft_group
      @draft_group ||= gobierto_participation_processes(:cultural_city_group_draft)
    end

    def future_closed_group
      @future_closed_group ||= gobierto_participation_processes(:public_debates_group_future)
    end

    def past_closed_group
      @past_closed_group ||= gobierto_participation_processes(:dance_studio_group_ended)
    end

    def bowling_group_very_active
      @bowling_group_very_active ||= gobierto_participation_processes(:bowling_group_very_active)
    end
    alias group_with_many_contributions bowling_group_very_active

    def find_participants_count_by_group_title(group_title)
      group_node = page.find('div.pure-u-1.pure-u-md-1-3', text: group_title)
      group_node.find('div.ib i.fa.fa-users').find(:xpath, '..').text().to_i
    end

    def find_interactions_count_by_group_title(group_title)
      group_node = page.find('div.pure-u-1.pure-u-md-1-3', text: group_title)
      group_node.find('div.ib i.fa.fa-comment').find(:xpath, '..').text().to_i
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within "nav.main-nav" do
          assert has_link? "Participation"
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit @path

        within "nav.sub-nav menu.secondary_nav" do
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
        assert has_no_link?(draft_group.title)
        assert has_link?(future_closed_group.title)
        assert has_link?(past_closed_group.title)

        # ensure body is properly formatted
        assert has_content? "Make Madrid a green city"
        assert has_no_content? "Make Madrid a <i>green city</i>"

        # check groups details

        assert_equal 8, find_interactions_count_by_group_title(group_with_many_contributions.title)
        assert_equal 3, find_participants_count_by_group_title(group_with_many_contributions.title)

        assert_equal 0, find_interactions_count_by_group_title(group_without_contributions.title)
        assert_equal 0, find_participants_count_by_group_title(group_without_contributions.title)
      end
    end

  end
end
