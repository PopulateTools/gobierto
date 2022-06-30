# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoAttachments
    module Api
      class AttachmentsController < ::GobiertoAdmin::Api::BaseController
        include ::GobiertoCommon::SecuredWithAdminToken
        skip_before_action :authenticate_admin!, :set_admin_with_token
        before_action :set_admin_by_session_or_token

        before_action :find_attachable, only: [:index]
        before_action :find_attachment, only: [:show, :destroy]
        before_action :load_collection, only: [:create, :update]

        def index
          attachments = if params[:search_string] && params[:search_string].present?
                          current_site.multisearch(params[:search_string], searchable_type: "GobiertoAttachments::Attachment", limit: 100, page: params[:page]).map(&:searchable)
                        elsif @attachable
                          @attachable.attachments.page(params[:page])
                        else
                          current_site.attachments.page(params[:page])
                        end

          render(
            json: { attachments: attachments.map { |a| default_serializer.new(a) } }
          )
        end

        def show
          render(json: { attachment: default_serializer.new(@attachment) } )
        end

        def create
          @file_attachment_form = FileAttachmentForm.new(
            attachment_params.merge(
              site_id: current_site.id,
              collection_id: collection_id,
              admin_id: current_admin.id
            )
          )

          if @file_attachment_form.save
            track_create_activity

            render(json: { attachment: default_serializer.new(@file_attachment_form.file_attachment) })
          else
            render(json: { error: "Invalid payload" }, status: :bad_request)
          end
        end

        def update
          @file_attachment_form = FileAttachmentForm.new(attachment_params.merge(
            id: params[:id],
            admin_id: current_admin.id,
            site_id: current_site.id,
            collection_id: collection_id
          ))

          if @file_attachment_form.save
            track_update_activity
            render(json: { attachment: default_serializer.new(@file_attachment_form.file_attachment) })
          else
            render(json: { errors: @file_attachment_form.errors.full_messages.to_sentence }, status: :bad_request)
          end
        end

        def destroy
          @attachment.destroy!

          render json: { message: "destroyed" }
        end

        private

        def find_attachment
          @attachment = current_site.attachments.find(params[:id])
        end

        def find_attachable
          attachable_id = params[:attachable_id]
          attachable_type = params[:attachable_type]

          if attachable_id && attachable_type && ::GobiertoAttachments.permitted_attachable_types.include?(attachable_type)
            attachable_class = attachable_type.constantize
            @attachable = attachable_class.find_by!(site: current_site, id: attachable_id)
          end
        end

        def default_serializer
          ::GobiertoAdmin::GobiertoAttachments::AttachmentSerializer
        end

        def attachment_params
          params.require(:attachment).permit(
            :id,
            :file,
            :name,
            :description,
            :collection_id,
            :file_name
          )
        end

        def load_collection
          @collection = attachment_params[:collection_id] ? current_site.collections.find(attachment_params[:collection_id]) : nil
        end

        def collection_id
          @collection ? @collection.id : nil
        end

        def track_create_activity
          Publishers::GobiertoAttachmentsAttachmentActivity.broadcast_event("attachment_created", default_activity_params.merge(subject: @file_attachment_form.file_attachment))
        end

        def track_update_activity
          Publishers::GobiertoAttachmentsAttachmentActivity.broadcast_event("attachment_updated", default_activity_params.merge(subject: @file_attachment_form.file_attachment))
        end

        def default_activity_params
          { ip: remote_ip, author: current_admin, site_id: current_site.id }
        end
      end
    end
  end
end
