module GobiertoAdmin
  module GobiertoAttachments
    module Api
      class AttachmentsController < ::GobiertoAdmin::Api::BaseController

        before_action :find_attachable, only: [:index]
        before_action :find_attachment, only: [:show, :update, :destroy]

        def index
          attachments = if params[:search_string]
                          ::GobiertoAttachments::Attachment.search(params[:search_string], page: params[:page])
                        elsif @attachable
                          @attachable.attachments.page(params[:page])
                        else
                          current_site.attachments.page(params[:page])
                        end

          render(
            json: { attachments: attachments.map{ |a| default_serializer.new(a) }}
          )
        end

        def show
          render(json: { attachment: default_serializer.new(@attachment) } )
        end

        def create
          attachment = ::GobiertoAttachments::Attachment.create!(
            attachment_params.merge(site: current_site, file: uploaded_file)
          )

          render(
            json: { attachment: default_serializer.new(attachment) }
          )
        end

        def update
          if attachment_params[:file]
            @attachment.update_attributes!(attachment_params.merge(file: uploaded_file))
          else
            @attachment.update_attributes!(attachment_params)
          end

          render(
            json: { attachment: default_serializer.new(@attachment) }
          )
        end

        def destroy
          @attachment.destroy!

          render json: { message: 'destroyed' }
        end

        private

        def find_attachment
          @attachment = current_site.attachments.find(params[:id])
        end

        def find_attachable
          attachable_id   = params[:attachable_id]
          attachable_type = params[:attachable_type]

          if attachable_id && attachable_type && ::GobiertoAttachments.permitted_attachable_types.include?(attachable_type)
            attachable_class = attachable_type.constantize
            @attachable = attachable_class.find_by!(site: current_site, id: attachable_id)
          end
        end

        def uploaded_file
          tmp_file = Tempfile.new('attachment_file')
          tmp_file.binmode
          tmp_file.write(Base64.strict_decode64(attachment_params[:file]))
          tmp_file.rewind
          # Mass assignment of file_name attribute is not permitted, it must always come from
          # an UploadedFile instance. Thus, we read it from params instead of attachment_params.
          ActionDispatch::Http::UploadedFile.new(filename: params[:attachment][:file_name], tempfile: tmp_file)
        rescue
          raise(PayloadError, 'Invalid payload')
        end

        def default_serializer
          ::GobiertoAdmin::GobiertoAttachments::AttachmentSerializer
        end

        def attachment_params
          params.require(:attachment).permit(
            :name,
            :description,
            :file
          )
        end

      end
    end
  end
end
