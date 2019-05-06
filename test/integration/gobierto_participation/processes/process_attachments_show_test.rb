# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessAttachmentsShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def process_attachment
      @process_attachment ||= gobierto_attachments_attachments(:pdf_collection_attachment)
    end

    def process_attachment_path
      @process_attachment_path ||= gobierto_attachments_document_path(
        process_attachment.slug
      )
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit process_attachment_path

        within "nav.main-nav" do
          assert has_link? "Participation"
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit process_attachment_path

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
        visit process_attachment_path

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
          visit process_attachment_path

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

    def test_process_attachment_show
      with_current_site(site) do
        visit process_attachment_path

        within "article.news_article" do
          assert has_link? "PDF Collection Attachment Name"
          assert has_content? "Description of a PDF attachment"
          assert has_content? "PDF · 9,8 KB"
        end

        click_link "See all documents"

        assert has_content? "Documents for #{process.title}"
      end
    end
  end
end
