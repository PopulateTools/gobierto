module GobiertoAdmin
  module GobiertoCms
    class FileAttachmentsController < BaseController
      before_action { module_enabled!(current_site, "GobiertoCms") }
      before_action { module_allowed!(current_admin, "GobiertoCms") }

      def create
        @file_attachment_form = FileAttachmentForm.new(
          file_attachment_params.merge(
            site: current_site,
            collection: "gobierto_cms"
          )
        )

        if @file_attachment_form.save
          render plain: @file_attachment_form.file_url
        else
          head :bad_request
        end
      end

      private

      def file_attachment_params
        params.require(:file_attachment).permit(:file)
      end
    end
  end
end
