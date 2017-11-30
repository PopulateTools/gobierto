module GobiertoAdmin
  module GobiertoAttachments
    class FileAttachmentsController < BaseController

      before_action :load_collection, only: [:new, :edit, :create, :update, :destroy]

      def index
        @collections = current_site.collections.by_item_type('GobiertoAttachments::Attachment')
        @file_attachments = ::GobiertoAttachments::Attachment.file_attachments_in_collections(current_site).sort_by_updated_at.limit(10)
        @site_file_attachments = current_site.attachments.sort_by_updated_at
      end

      def new
        @file_attachment_form = FileAttachmentForm.new(site_id: current_site.id, collection_id: collection_id)
      end

      def edit
        @file_attachment = find_file_attachment
        @file_attachment_form = FileAttachmentForm.new(
          @file_attachment.attributes.except(*ignored_file_attachment_attributes).merge(site_id: current_site.id, collection_id: collection_id)
        )
      end

      def create
        @file_attachment_form = FileAttachmentForm.new(
          file_attachment_params.merge(
            site_id: current_site.id,
            collection_id: collection_id,
            admin_id: current_admin.id
          )
        )
        if @file_attachment_form.save
          redirect_to(
            edit_admin_attachments_file_attachment_path(@file_attachment_form.file_attachment.id, collection_id: collection_id),
            notice: t(".success_html", link: @file_attachment_form.file_attachment.to_url(host: current_site.domain))
          )
        else
          render :edit
        end
      end

      def update
        @file_attachment = find_file_attachment

        @file_attachment_form = FileAttachmentForm.new(file_attachment_params.merge(
          id: params[:id],
          admin_id: current_admin.id,
          site_id: current_site.id,
          collection_id: collection_id
        ))

        if @file_attachment_form.save
          redirect_to(
            edit_admin_attachments_file_attachment_path(@file_attachment_form.file_attachment.id, collection_id: collection_id),
            notice: t(".success_html", link: @file_attachment_form.file_attachment.to_url(host: current_site.domain))
          )
        else
          render :edit, collection_id: collection_id
        end
      end

      private

      def load_collection
        @collection = params[:collection_id] ? current_site.collections.find(params[:collection_id]) : nil
      end

      def collection_id
        @collection ? @collection.id : nil
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def find_file_attachment
        current_site.attachments.find(params[:id])
      end

      def find_collection(collection_id)
        ::GobiertoCommon::Collection.find_by(id: collection_id)
      end

      def ignored_file_attachment_attributes
        %w(created_at updated_at site_id file_size current_version collection_id)
      end

      def file_attachment_params
        params.require(:file_attachment).permit(:id, :file, :name, :description, :file_name, :slug, :collection_id)
      end
    end
  end
end
