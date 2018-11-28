# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ScopeAttachmentsIndexTest < ActionDispatch::IntegrationTest
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

    def scope_attachments_path
      @scope_attachments_path ||= gobierto_participation_scope_attachments_path(
        scope_id: scope.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def scope_attachments
      @scope_attachments ||= scope.attachments
    end

    def test_menu_subsections
      with_current_site(site) do
        visit scope_attachments_path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit scope_attachments_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_scope_attachments_index
      with_current_site(site) do
        visit scope_attachments_path

        assert_equal scope_attachments.size, all(".news_teaser").size

        assert has_link? "XLSX Attachment Event"
        assert has_link? "PDF Collection Attachment Name"
      end
    end

    def test_update_process_scope_attachments_index
      participation_process.update_attribute(:scope_id, other_scope.id)

      with_current_site(site) do
        visit scope_attachments_path

        assert_equal scope_attachments.size, all(".news_teaser").size

        refute has_link? "XLSX Attachment Event"
        refute has_link? "PDF Collection Attachment Name"
      end
    end
  end
end
