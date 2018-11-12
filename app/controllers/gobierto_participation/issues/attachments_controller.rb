# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class AttachmentsController < GobiertoParticipation::ApplicationController
      include ::PreviewTokenHelper

      def index
        @issue = find_issue
        @attachments = find_issue_attachments
      end

      private

      def find_issue_attachments
        ::GobiertoAttachments::Attachment.in_collections_and_container(current_site, @issue)
      end
    end
  end
end
