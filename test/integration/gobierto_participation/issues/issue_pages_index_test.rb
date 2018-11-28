# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class IssuePagesIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def issue
      @issue ||= ProcessTermDecorator.new(gobierto_common_terms(:women_term))
    end

    def other_issue
      @other_issue ||= gobierto_common_terms(:economy_term)
    end

    def participation_process
      @participation_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def issue_pages_path
      @issue_pages_path ||= gobierto_participation_news_index_path(
        issue_id: issue.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def issue_news
      @issue_news ||= issue.news
    end

    def test_menu_subsections
      with_current_site(site) do
        visit issue_pages_path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit issue_pages_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_issue_pages_index
      with_current_site(site) do
        visit issue_pages_path

        assert_equal issue_news.active.size, all(".news_teaser").size

        assert has_link? "Notice 1 title"
        assert has_link? "Notice 2 title"
      end
    end

    def test_update_process_issue_pages_index
      participation_process.update_attribute(:issue_id, other_issue.id)

      with_current_site(site) do
        visit issue_pages_path

        assert_equal issue_news.active.size, all(".news_teaser").size

        refute has_link? "Notice 1 title"
        refute has_link? "Notice 2 title"
      end
    end
  end
end
