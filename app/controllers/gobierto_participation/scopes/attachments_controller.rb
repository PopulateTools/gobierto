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

      def find_scope_attachments
        @scope.attachments
      end
    end
  end
end
