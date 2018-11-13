# frozen_string_literal: true

module GobiertoParticipation
  class AttachmentsController < GobiertoParticipation::ApplicationController
    def index
      @issue = find_issue if params[:issue_id]
      @issues = find_issues
      @filtered_issue = find_issue if params[:issue_id]
      @attachments = if @filtered_issue
                       GobiertoAttachments::Attachment.in_collections_and_container(current_site, @issue).page(params[:page])
                     else
                       find_attachments.page(params[:page])
                     end
    end

    private

    def find_attachments
      attachments = ::GobiertoAttachments::Attachment.in_collections_and_container_type(current_site, "GobiertoParticipation")

      if @filtered_issue
        attachments = attachments.in_collections_and_container(current_site, @filtered_issue)
      end

      attachments
    end
  end
end
