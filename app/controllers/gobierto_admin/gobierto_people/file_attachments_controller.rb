module GobiertoAdmin
  module GobiertoPeople
    class FileAttachmentsController < BaseController
      before_action { module_enabled!(current_site, "GobiertoPeople") }

      def create
        @file_attachment_form = FileAttachmentForm.new(
          file_attachment_params.merge(base_path: "gobierto_people")
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
