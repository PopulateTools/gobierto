module GobiertoAdmin
  module GobiertoAttachments
    module Api
      class AttachingsController < ::GobiertoAdmin::Api::BaseController

        before_action :find_attachment, :find_attachable

        def create
          attaching = @attachable.link_attachment(@attachment)

          render json: { attachment: AttachmentSerializer.new(@attachment) }
        end

        def destroy
          @attachable.unlink_attachment(@attachment)

          render json: { message: 'destroyed' }
        end

        private

        def find_attachment
          @attachment = current_site.attachments.find(params[:attachment_id])
        end

        def find_attachable
          attachable_type = params[:attachable_type]

          if ::GobiertoAttachments.permitted_attachable_types.include?(attachable_type)
            attachable_class = attachable_type.constantize
            @attachable = attachable_class.find_by(site_id: params[:site_id], id: params[:attachable_id])
          end
        end

        def attaching_params
          params.require(:site_id, :attachment_id, :attachable_id, :attachable_type)
        end

      end
    end
  end
end
