# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ScopePagesIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def scope
      @scope ||= gobierto_common_terms(:old_town_term)
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
      @scope_news ||= GobiertoCms::Page.news_in_collections_and_container(site, scope).sorted
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

        assert_equal scope_news.size, all(".news_teaser").size

        assert has_content? "News for Old town"
      end
    end
  end
end
