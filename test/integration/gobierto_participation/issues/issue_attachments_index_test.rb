# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class IssueAttachmentsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def issue
      @issue ||= ProcessTermDecorator.new(gobierto_common_terms(:women_term))
    end

    def issue_attachments_path
      @issue_attachments_path ||= gobierto_participation_issue_attachments_path(
        issue_id: issue.slug
      )
    end

    def user
      @user ||= users(:peter)
    end

    def issue_attachments
      @issue_attachments ||= ::GobiertoAttachments::Attachment.in_collections_and_container(site, issue)
    end

    def test_menu_subsections
      with_current_site(site) do
        visit issue_attachments_path

        within "nav.sub-nav" do
          assert has_link? "Scopes"
          assert has_link? "Processes"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit issue_attachments_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_issue_attachments_index
      with_current_site(site) do
        visit issue_attachments_path

        assert_equal issue_attachments.size, all(".news_teaser").size

        assert has_link? "XLSX Attachment Event"
        assert has_link? "PDF Collection Attachment Name"
      end
    end
  end
end
