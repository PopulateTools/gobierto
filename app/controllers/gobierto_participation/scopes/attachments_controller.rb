# frozen_string_literal: true

module GobiertoParticipation
  module Scopes
    class AttachmentsController < GobiertoParticipation::ApplicationController
      include ::PreviewTokenHelper

      def index
        @scope = find_scope
        @attachments = find_scope_attachments
      end

      private

      def find_scope
        current_site.scopes.find_by_slug!(params[:scope_id])
      end

      def find_scope_attachments
        ::GobiertoAttachments::Attachment.attachments_in_collections_and_container(current_site, @scope)
      end
    end
  end
end
