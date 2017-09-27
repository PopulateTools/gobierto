# frozen_string_literal: true

module GobiertoParticipation
  module Issues
    class AttachmentsController < BaseController
      include ::PreviewTokenHelper

      before_action :find_attachment_by_id_and_redirect

      def show
        @process = find_process if params[:process_id]
        @attachment = find_attachment
        @groups = current_site.processes.group_process
      end

      def index
        @issues = current_site.issues
        @issue = find_issue
        @attachments = find_issue_news.attachment(params[:attachment])
      end

      private

      # Load attachment by ID is necessary to keep the search results attachment unified and simple
      def find_attachment_by_id_and_redirect
        if params[:id].present? && params[:id] =~ /\A\d+\z/
          attachment = current_site.attachments.active.find(params[:id])
          redirect_to gobierto_cms_attachment_path(attachment.slug) and return false
        end
      end

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_issue_news
        @issue.news
      end

      def find_attachment
        attachments_scope.find_by_slug!(params[:id])
      end

      def attachments_scope
        valid_preview_token? ? current_site.attachments.draft : current_site.attachments.active
      end
    end
  end
end
