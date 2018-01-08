# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessFileAttachmentsController < Processes::BaseController
        def index
          @collection = current_process.attachments_collection
          @file_attachments = ::GobiertoAttachments::Attachment.where(id: @collection.file_attachments_in_collection).sorted
          @archived_file_attachments = current_site.attachments.only_archived.where(collection_id: @collection.id).sorted
        end
      end
    end
  end
end
