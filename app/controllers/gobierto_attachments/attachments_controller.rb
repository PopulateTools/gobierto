# frozen_string_literal: true

module GobiertoAttachments
  class AttachmentsController < GobiertoAttachments::ApplicationController

    include ::PreviewTokenHelper

    before_action :load_attachment
    layout false

    def show
      if direct_visit?
        render "show"
      else
        redirect_to @attachment.url
      end
    end

    private

    def direct_visit?
      # When the browser loads the page adds the Accept header "text/html", otherwise
      # it uses a different header.
      # For example, when the doc URL is used in an <img> tag, in Firefox the
      # Accept header is */*, and in Safari is the MIME-Type of the image.
      accept_header = request.headers["Accept"]
      accept_header&.include?("text/html")
    end

    def load_attachment
      @attachment = site_attachments.find_by(id: params[:id]) || site_attachments.find_by!(slug: params[:id])
      raise ActiveRecord::RecordNotFound unless @attachment.public? || valid_preview_token?
    end

    def site_attachments
      current_site.attachments
    end

  end
end
