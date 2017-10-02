module GobiertoAdmin
  module GobiertoAttachments
    class FileAttachmentsController < BaseController
      def index
        @collections = current_site.collections.by_item_type('GobiertoAttachments::Attachment')
        @file_attachments = ::GobiertoAttachments::Attachment.file_attachments_in_collections(current_site).sort_by_updated_at(10)
      end

      def new
        @file_attachment_form = FileAttachmentForm.new(site_id: current_site.id)
        @collection = find_collection(params[:collection_id])
      end

      def edit
        @file_attachment = find_file_attachment
        @collection = @file_attachment.collection
        @file_attachment_form = FileAttachmentForm.new(
          @file_attachment.attributes.except(*ignored_file_attachment_attributes).merge(site_id: current_site.id)
        )
      end

      def create
        @file_attachment_form = FileAttachmentForm.new(
          file_attachment_params.merge(
            site_id: current_site.id,
            collection: 'gobierto_cms'
          )
        )
        @collection = ::GobiertoCommon::Collection.find(params[:file_attachment][:collection_id])

        if @file_attachment_form.save
          track_create_activity
          ::GobiertoCommon::Collection.find(params[:file_attachment][:collection_id]).append(@file_attachment_form.file_attachment)

          if params[:file_attachment][:collection_id]
            redirect_to(
              edit_admin_attachments_file_attachment_path(@file_attachment_form.file_attachment.id, collection_id: params[:file_attachment][:collection_id]),
              notice: t(".success_html", link: @file_attachment_form.file_attachment.to_url(host: current_site.domain))
            )
          else
            render plain: @file_attachment_form.file_url
          end
        else
          if params[:file_attachment][:collection_id]
            @collection = ::GobiertoCommon::Collection.find(params[:file_attachment][:collection_id])
            render :edit
          else
            head :bad_request
          end
        end
      end

      def update
        @file_attachment = find_file_attachment
        @file_attachment_form = FileAttachmentForm.new(file_attachment_params.merge(id: params[:id], site_id: current_site.id))
        if @file_attachment_form.save
          track_update_activity

          redirect_to(
            edit_admin_attachments_file_attachment_path(@file_attachment_form.file_attachment.id),
            notice: t(".success_html", link: @file_attachment_form.file_attachment.to_url(host: current_site.domain))
          )
        else
          @collection = @page.file_attachment
          render :edit, collection_id: @collection.id
        end
      end

      private

      def track_create_activity
        Publishers::GobiertoAttachmentsAttachmentActivity.broadcast_event('attachment_created', default_activity_params.merge(subject: @file_attachment_form.file_attachment))
      end

      def track_update_activity
        Publishers::GobiertoAttachmentsAttachmentActivity.broadcast_event('attachment_updated', default_activity_params.merge(subject: @file_attachment))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def find_file_attachment
        current_site.attachments.find(params[:id])
      end

      def find_collection(collection_id)
        ::GobiertoCommon::Collection.find_by(id: params[:collection_id])
      end

      def ignored_file_attachment_attributes
        %w( created_at updated_at site_id file_size current_version)
      end

      def file_attachment_params
        params.require(:file_attachment).permit(:id, :file, :name, :description, :file_name, :slug)
      end
    end
  end
end
