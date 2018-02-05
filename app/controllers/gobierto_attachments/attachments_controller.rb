module GobiertoAttachments
  class AttachmentsController < GobiertoAttachments::ApplicationController

    before_action :load_attachment
    layout false

    def show
      if @attachment.file_size < 100.megabytes
        tempfile = open(@attachment.url)
        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(tempfile.path, true)

        send_data(
          tempfile.read,
          filename: @attachment.file_name,
          type: mime_type,
          disposition: 'inline',
          stream: 'true',
          buffer_size: '4096'
        )
      else
        redirect_to @attachment.url
      end
    end

    private

    def load_attachment
      @attachment = current_site.attachments.find(params[:id])
    end

  end
end
