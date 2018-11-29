# frozen_string_literal: true

module GobiertoParticipation
  class AttachmentsController < GobiertoParticipation::ApplicationController
    def index
      @issue = find_issue if params[:issue_id]
      @issues = find_issues
      @filtered_issue = find_issue if params[:issue_id]
      @attachments = find_attachments.page(params[:page])
    end

    private

    def find_attachments
      if @filtered_issue
        @issue.attachments
      else
        ::GobiertoAttachments::Attachment.in_collections_and_container_type(current_site, "GobiertoParticipation")
      end
    end
  end
end
