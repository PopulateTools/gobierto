# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ScopePagesIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def scope
      @scope ||= ProcessTermDecorator.new(gobierto_common_terms(:old_town_term))
    end

    def other_scope
      @other_scope ||= gobierto_common_terms(:center_term)
    end

    def participation_process
      @participation_process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def scope_pages_path
      @scope_pages_path ||= gobierto_participation_news_index_path(
        scope_id: scope.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def scope_news
      @scope_news ||= scope.news
    end

    def test_menu_subsections
      with_current_site(site) do
        visit scope_pages_path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit scope_pages_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_scope_pages_index
      with_current_site(site) do
        visit scope_pages_path

        assert_equal scope_news.active.size, all(".news_teaser").size

        assert has_link? "Notice 1 title"
        assert has_link? "Notice 2 title"
        assert has_link? "Themes in the site"

        assert has_content? "News for Old town"
      end
    end

    def test_update_process_scope_pages_index
      participation_process.update_attribute(:scope_id, other_scope.id)

      with_current_site(site) do
        visit scope_pages_path

        assert_equal scope_news.active.size, all(".news_teaser").size

        refute has_link? "Notice 1 title"
        refute has_link? "Notice 2 title"
        assert has_link? "Themes in the site"

        assert has_content? "News for Old town"
      end
    end
  end
end
