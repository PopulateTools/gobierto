# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class AttachmentsController < BaseController
      include ::PreviewTokenHelper

      def index
        @issues = current_site.issues
        @filtered_issue = find_issue if params[:issue_id]
        @issue = find_issue if params[:issue_id]
        @attachments = if @issue
                         GobiertoAttachments::Attachment.attachments_in_collections_and_container(current_site, @issue)
                                                        .attachments_in_collections_and_container(current_site, current_process).page(params[:page])
                       else
                         find_process_attachments
                       end
      end

      private

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_process_attachments
        ::GobiertoAttachments::Attachment.attachments_in_collections_and_container(current_site, current_process)
      end
    end
  end
end
