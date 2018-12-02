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
        ProcessCollectionDecorator.new(current_site.attachments).in_participation_module
      end
    end
  end
end
