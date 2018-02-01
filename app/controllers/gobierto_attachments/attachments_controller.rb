module GobiertoAttachments
  class AttachmentsController < GobiertoAttachments::ApplicationController

    before_action :load_attachment
    layout false

    def show
    end

    private

    def load_attachment
      obscured_id = params[:id]
      @attachment = current_site.attachments.find(Attachment.get_clear_id(obscured_id))
    end

  end
end
