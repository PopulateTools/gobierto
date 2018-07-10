# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class IssueIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_participation_issues_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def issues
      @issues ||= site.issues.sorted
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
          assert has_content? "Scopes"
          assert has_content? "Processes"
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
      end
    end

    def test_issues_index
      with_current_site(site) do
        visit @path

        issues.each do |issue|
          assert has_link?(issue.name)
        end
      end
    end
  end
end
