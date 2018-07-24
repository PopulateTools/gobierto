module GobiertoAdmin
  module GobiertoAttachments
    module Api
      class AttachingsController < ::GobiertoAdmin::Api::BaseController

        before_action :find_attachment, :find_attachable
        before_action { gobierto_module_enabled!(current_site, "GobiertoAttachments", false) }
        before_action { module_allowed!(current_admin, "GobiertoAttachments") }

        def create
          if attaching = @attachable.link_attachment(@attachment)
            render json: { attachment: AttachmentSerializer.new(@attachment) }
          else
            head :bad_request
          end
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
            @attachable = attachable_class.find_by(site: current_site, id: params[:attachable_id])
          end
        end

        def attaching_params
          params.require(:attachment_id, :attachable_id, :attachable_type)
        end

      end
    end
  end
end
