module GobiertoAdmin
  module GobiertoAttachments
    module Api
      class AttachmentsController < ::GobiertoAdmin::Api::BaseController

        before_action :find_attachable, only: [:index]
        before_action :open_tempfile,   only: [:create, :update]
        after_action  :close_tempfile,  only: [:create, :update]

        def index
          if params[:search_string]
            attachments = ::GobiertoAttachments::Attachment.search(params[:search_string])
          elsif @attachable
            attachments = @attachable.attachments
          else
            attachments = current_site.attachments
          end

          render json: attachments, each_serializer: default_serializer
        end

        def create
          attachment = ::GobiertoAttachments::Attachment.new(
            attachment_params.merge!(file: uploaded_file)
          )

          attachment.save!

          render json: { attachment: default_serializer.new(attachment) }
        end

        def update
          attachment = current_site.attachments.find(params[:attachment][:id])

          attachment.update_attributes!(
            attachment_params.merge!(file: uploaded_file)
          )

          render json: { attachment: default_serializer.new(attachment) }
        end

        def destroy
          attachment = current_site.attachments.find(params[:attachment][:id])
          attachment.destroy!

          render json: { message: 'destroyed' }
        end

        private

        def find_attachable
          attachable_params = params[:attachable]

          if attachable_params && ::GobiertoAttachments.permitted_attachable_types.include?(attachable_params[:type])
            attachable_class = attachable_params[:type].constantize
            @attachable = attachable_class.find_by(site_id: params[:site_id], id: attachable_params[:id])
          end
        end

        def uploaded_file
          file_content = Base64.decode64(attachment_params[:file])
          @tmp_file.write(file_content)
          ActionDispatch::Http::UploadedFile.new(filename: attachment_params[:file_name], tempfile: @tmp_file)
        rescue
          raise(PayloadError, 'Invalid payload')
        end

        def open_tempfile
          @tmp_file = Tempfile.new('attachment_file')
          @tmp_file.binmode
        end

        def close_tempfile
          @tmp_file.close
        end

        def default_serializer
          ::GobiertoAdmin::GobiertoAttachments::AttachmentSerializer
        end

        def attachment_params
          params.require(:attachment).permit(
            :site_id,
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
