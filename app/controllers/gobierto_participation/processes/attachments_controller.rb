# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class AttachmentsController < BaseController
      include ::PreviewTokenHelper

      def show
        @attachment = find_attachment
        @groups = current_site.processes.group_process
        @issues = current_site.issues
      end

      def index
        @issues = current_site.issues
        @filtered_issue = find_issue if params[:issue_id]
        @attachments = find_process_attachments
      end

      private

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_attachment
        # TODO: pending create slug
        # find_process_attachments.find_by_slug!(params[:id])
        find_process_attachments.find_by_id!(params[:id])
      end

      def find_process_attachments
        ::GobiertoAttachments::Attachment.attachments_in_collections_and_container(current_site, current_process)
      end
    end
  end
end
