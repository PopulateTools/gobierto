module GobiertoAdmin
  module GobiertoAttachments
    module Api
      class AttachmentsController < ::GobiertoAdmin::Api::BaseController

        before_action :find_attachable, only: [:index]
        before_action :find_attachment, only: [:update, :destroy]

        def index
          if params[:search_string]
            attachments = ::GobiertoAttachments::Attachment.search(params[:search_string], page: params[:page])
          elsif @attachable
            attachments = @attachable.attachments.page(params[:page])
          else
            attachments = current_site.attachments.page(params[:page])
          end

          render(
            json: { attachments: attachments },
            each_serializer: default_serializer
          )
        end

        def create
          attachment = ::GobiertoAttachments::Attachment.new(
            attachment_params.merge!(site: current_site, file: uploaded_file)
          )

          attachment.save!

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
            @attachable = attachable_class.find_by(site: current_site, id: attachable_id)
          end
        end

        def uploaded_file
          @tmp_file = Tempfile.new('attachment_file')
          @tmp_file.binmode
          file_content = Base64.decode64(attachment_params[:file])
          @tmp_file.write(file_content)
          @tmp_file.close
          ActionDispatch::Http::UploadedFile.new(filename: attachment_params[:file_name], tempfile: @tmp_file)
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
            :file_name,
            :file
          )
        end

      end
    end
  end
end
