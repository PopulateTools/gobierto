# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessEventsShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_issue_path(:culture)
    end

    def site
      @site ||= sites(:madrid)
    end

    def issue
      @issue ||= issues(:culture)
    end

    def processes
      @processes ||= site.processes.process.where(issue: issue).open
    end

    def groups
      @groups ||= site.processes.group_process.where(issue: issue)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within ".global_breadcrumb" do
          assert has_link? "Participation"
          assert has_link? "Issues"
          assert has_link? issue.name
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
        # applying the right scope (single process/group scope)
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within ".site_header" do
          assert has_content? "Follow this process"
        end
      end
    end

    def test_issue
      with_current_site(site) do
        visit @path

        within ".container" do
          assert has_content? issue.name
          assert has_content? issue.description
        end
      end
    end

    def test_issue_news
      with_current_site(site) do
        visit @path
        assert_equal issue.news_in_collections.size, all("div#news/div").size
      end
    end

    def test_issue_without_events
      with_current_site(site) do
        visit @path

        assert has_content? "There are no related events"
      end
    end

    def test_issue_processes
      with_current_site(site) do
        visit @path

        assert_equal processes.size, all("div#processes/div").size
      end
    end

    def test_issue_groups
      with_current_site(site) do
        visit @path

        assert_equal groups.size, all("div#groups/div").size
      end
    end
  end
end
