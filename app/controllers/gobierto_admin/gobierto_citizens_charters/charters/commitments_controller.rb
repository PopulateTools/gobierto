# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class CommitmentsController < GobiertoCitizensCharters::BaseController
        before_action :set_charter

        def index
          @commitments = @charter.commitments
          @archived_commitments = @commitments.only_archived
        end

        def new
          @commitment_form = CommitmentForm.new(
            commitments_relation.new.attributes.except(*ignored_commitment_attributes).merge(site_id: current_site.id, charter_id: @charter.id)
          )
          render(:new_modal, layout: false) && return if request.xhr?
        end

        def edit
          load_commitment

          @commitment_form = CommitmentForm.new(
            @commitment.attributes.except(*ignored_commitment_attributes).merge(site_id: current_site.id)
          )
          render(:edit_modal, layout: false) && return if request.xhr?
        end

        def create
          @commitment_form = CommitmentForm.new(commitment_params.merge(site_id: current_site.id, charter_id: @charter.id, admin_id: current_admin.id))

          if @commitment_form.save
            redirect_to(
              admin_citizens_charters_charter_commitments_path(@charter),
              notice: t(".success_html", link: preview_url(@commitment_form.resource, host: current_site.domain))
            ) && return
          else
            render(:new_modal, layout: false) && return if request.xhr?
            render :new
          end
        end

        def update
          load_commitment

          @commitment_form = CommitmentForm.new(commitment_params.merge(id: params[:id], site_id: current_site.id, charter_id: @commitment.charter.id, admin_id: current_admin.id))

          if @commitment_form.save
            redirect_to(
              admin_citizens_charters_charter_commitments_path(@commitment_form.resource.charter),
              notice: t(".success_html", link: preview_url(@commitment_form.resource, host: current_site.domain))
            ) && return
          else
            render(:edit_modal, layout: false) && return if request.xhr?
            render :edit
          end
        end

        def destroy
          load_commitment
          charter = @commitment.charter
          @commitment_form = CommitmentForm.new(id: @commitment.id, site_id: current_site.id, charter_id: charter.id, admin_id: current_admin.id)

          if @commitment_form.destroy
            redirect_to admin_citizens_charters_charter_commitments_path(charter), notice: t(".success")
          else
            redirect_to admin_citizens_charters_charter_commitments_path(charter), alert: t(".destroy_failed")
          end
        end

        protected

        def load_commitment
          @commitment = commitments_relation.find(params[:id])
        end

        def commitments_relation
          @charter.commitments
        end

        def commitment_params
          params.require(:commitment).permit(
            :slug,
            :visibility_level,
            title_translations: [*I18n.available_locales],
            description_translations: [*I18n.available_locales]
          )
        end

        def set_charter
          @charter = current_site.charters.find(params[:charter_id])
        end

        def ignored_commitment_attributes
          %w(position archived_at created_at updated_at)
        end
      end
    end
  end
end
