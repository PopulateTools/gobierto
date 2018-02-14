# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ParticipationAttachmentsShowTest < ActionDispatch::IntegrationTest
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:peter)
    end

    def participation_attachment
      @participation_attachment ||= gobierto_attachments_attachments(:pdf_on_participation)
    end

    def participation_attachment_path
      @participation_attachment_path ||= gobierto_participation_attachment_path(participation_attachment.slug)
    end

    def test_secondary_nav
      with_current_site(site) do
        visit participation_attachment_path

        within "nav.sub-nav menu.secondary_nav" do
          assert has_link? "News"
          assert has_link? "Agenda"
          assert has_link? "Documents"
          assert has_link? "Activity"
        end
      end
    end

    def test_participation_attachment_show
      with_current_site(site) do
        visit participation_attachment_path

        assert has_content? "PDF Collection On Participation"

        click_link "See all documents"

        assert has_no_content? "Documents on Participation"
      end
    end
  end
end
