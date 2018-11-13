# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessAttachmentsIndexTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_attachments_path
      @process_attachments_path ||= gobierto_participation_process_attachments_path(
        process_id: process.slug
      )
    end

    def process_attachments
      @process_attachments ||= ::GobiertoAttachments::Attachment.in_collections_and_container(site, process)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_attachments_path

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_attachments_path

        within "nav.sub-nav" do
          assert has_link? "Information"
          assert has_link? "Agenda"
          assert has_no_link? "Polls"
          assert has_no_link? "Contributions"
          assert has_no_link? "Results"
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit process_attachments_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_subscription_block
      with_javascript do
        with_signed_in_user(user) do
          visit process_attachments_path

          within ".slim_nav_bar" do
            assert has_link? "Follow process"
          end

          click_on "Follow process"
          assert has_link? "Process followed!"

          click_on "Process followed!"
          assert has_link? "Follow process"
        end
      end
    end

    def test_process_attachments_index
      with_current_site(site) do
        visit process_attachments_path

        assert_equal process_attachments.size, all(".news_teaser").size
        assert has_content? "PDF Collection Attachment Name"
      end
    end

    def test_process_event_show_see_all_events
      with_current_site(site) do
        visit process_attachments_path

        click_link "See all documents"

        assert has_content? "Documents for Participation"

        assert has_link? "PDF Collection On Participation"
        assert has_link? "XLSX Attachment Event"
        assert has_link? "PDF Collection Attachment Name"
      end
    end
  end
end
