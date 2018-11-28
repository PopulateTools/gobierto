# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class AttachmentsController < BaseController
      include ::PreviewTokenHelper

      def index
        @issues = find_issues
        @filtered_issue = find_issue if params[:issue_id]
        @issue = find_issue if params[:issue_id]
        @attachments = if @issue
                         @issue.attachments.in_collections_and_container(current_site, current_process).page(params[:page])
                       else
                         find_process_attachments
                       end
      end

      private

      def find_process_attachments
        ::GobiertoAttachments::Attachment.in_collections_and_container(current_site, current_process).page(params[:page])
      end
    end
  end
end
