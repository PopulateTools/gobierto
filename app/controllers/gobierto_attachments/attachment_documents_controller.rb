# frozen_string_literal: true

module GobiertoAttachments
  class AttachmentDocumentsController < GobiertoAttachments::ApplicationController
    helper_method :current_process
    before_action :load_attachment
    before_render :set_context

    def show
      @collection = @attachment.collection
      render layout: @attachment.layout if @attachment.layout
    end

    private

    def load_attachment
      @attachment = GobiertoAttachments::AttachmentDecorator.new(current_site.attachments.find_by(id: params[:id]) || current_site.attachments.find_by!(slug: params[:id]))
    end

    def current_process
      @current_process
    end

    def set_context
      @current_module = @attachment.module
      @current_process ||= (@collection && @collection.container_type == "GobiertoParticipation::Process") ? @collection.container : nil
    end
  end
end
