module GobiertoAdmin
  module GobiertoCms
    class FileAttachmentsController < BaseController
      before_action { module_enabled!(current_site, 'GobiertoCms') }
      before_action { module_allowed!(current_admin, 'GobiertoCms') }

      def index
        @collections = current_site.collections.by_item_type('GobiertoAttachments::Attachment')
        @file_attachments = current_site.attachments
      end

      def new
        @file_attachment_form = FileAttachmentForm.new(site: current_site)
      end

      def edit
        @file_attachment = find_file_attachment
        @file_attachment_form = FileAttachmentForm.new(
          @file_attachment.attributes.except(*ignored_file_attachment_attributes)
        )
      end

      def create
        @file_attachment_form = FileAttachmentForm.new(
          file_attachment_params.merge(
            site: current_site,
            collection: 'gobierto_cms'
          )
        )

        if @file_attachment_form.save
          ::GobiertoCommon::Collection.find(params[:file_attachment][:collection_id]).append(@file_attachment_form.file_attachment)

          # TODO: Pending add hidden attribute
          if true
            redirect_to edit_admin_cms_file_attachment_path(@file_attachment_form.file_attachment.id)
          else
            render plain: @file_attachment_form.file_url
          end
        else
          if true
            render :edit
          else
            head :bad_request
          end
        end
      end

      private

      def find_file_attachment
        current_site.attachments.find(params[:id])
      end

      def ignored_file_attachment_attributes
        %w( created_at updated_at id site_id file_size current_version)
      end

      def file_attachment_params
        params.require(:file_attachment).permit(:file, :name, :description, :file_name)
      end
    end
  end
end
