# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ParticipationAttachmentsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def participation_attachments_path
      @participation_attachments_path ||= gobierto_participation_attachments_path
    end

    def participation_attachments
      @participation_attachments ||= GobiertoParticipation::ProcessCollectionDecorator.new(site.attachments).in_participation_module
    end

    def participation_process
      @participation_process ||= gobierto_participation_processes :bowling_group_very_active
    end

    def test_secondary_nav
      with_current_site(site) do
        visit participation_attachments_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_participation_attachments_index
      with_current_site(site) do
        visit participation_attachments_path

        assert_equal participation_attachments.size, all(".news_teaser").size

        assert has_no_content? "See all documents"

        assert has_link? "PDF Collection On Participation"
        assert has_link? "XLSX Attachment Event"
        assert has_link? "PDF Collection Attachment Name"
        assert has_link? "PDF Collection On Process"
      end
    end

    def test_participation_process_draft
      participation_process.draft!

      with_current_site(site) do
        visit participation_attachments_path

        assert_equal participation_attachments.size, all(".news_teaser").size

        assert has_no_content? "See all documents"

        assert has_link? "PDF Collection On Participation"
        assert has_link? "XLSX Attachment Event"
        assert has_link? "PDF Collection Attachment Name"
        assert has_no_content? "PDF Collection On Process"
      end
    end

    def test_participation_process_archived
      participation_process.destroy

      with_current_site(site) do
        visit participation_attachments_path

        assert_equal participation_attachments.size, all(".news_teaser").size

        assert has_no_content? "See all documents"

        assert has_link? "PDF Collection On Participation"
        assert has_link? "XLSX Attachment Event"
        assert has_link? "PDF Collection Attachment Name"
        assert has_no_content? "PDF Collection On Process"
      end
    end
  end
end
