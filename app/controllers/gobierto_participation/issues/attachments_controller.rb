# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class AttachmentsController < GobiertoParticipation::BaseController
      include ::PreviewTokenHelper

      def show
        @attachment = find_attachment
        @groups = current_site.processes.group_process
        @issue = find_issue
      end

      def index
        @issue = find_issue
        @attachments = find_issue_attachments
      end

      private

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_attachment
        find_issue_attachments.find_by_slug!(params[:id])
      end

      def find_issue_attachments
        ::GobiertoAttachments::Attachment.attachments_in_collections_and_container(current_site, @issue)
      end
    end
  end
end
