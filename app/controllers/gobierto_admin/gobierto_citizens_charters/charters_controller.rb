# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class ChartersController < GobiertoCitizensCharters::BaseController
      def index
        @charters = charters_relation
        @archived_charters = charters_relation.only_archived
      end

      def new
        @charter_form = CharterForm.new(
          charters_relation.new.attributes.except(*ignored_charter_attributes).merge(site_id: current_site.id)
        )
        render(:new_modal, layout: false) && return if request.xhr?
      end

      def edit
        load_charter

        @charter_form = CharterForm.new(
          @charter.attributes.except(*ignored_charter_attributes).merge(site_id: current_site.id)
        )
        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def create
        @charter_form = CharterForm.new(charter_params.merge(site_id: current_site.id))

        if @charter_form.save
          redirect_to(
            admin_citizens_charters_charters_path,
            notice: t(".success_html", link: preview_url(@charter_form.resource, host: current_site.domain))
          ) && return
        else
          render(:new_modal, layout: false) && return if request.xhr?
          render :new
        end
      end

      def update
        @charter_form = CharterForm.new(charter_params.merge(id: params[:id], site_id: current_site.id))

        if @charter_form.save
          redirect_to(
            admin_citizens_charters_charters_path,
            notice: t(".success_html", link: preview_url(@charter_form.resource, host: current_site.domain))
          ) && return
        else
          render(:edit_modal, layout: false) && return if request.xhr?
          render :edit
        end
      end

      def destroy
        load_charter

        if @charter.destroy
          redirect_to admin_citizens_charters_charters_path, notice: t(".success")
        else
          redirect_to admin_citizens_charters_charters_path, alert: t(".destroy_failed")
        end
      end

      def recover
        @charter = current_site.charters.only_deleted.find(params[:charter_id])
        if @charter.belongs_to_archived?
          redirect_to admin_citizens_charters_charters_path, alert: t(".recover_failed")
        else
          @charter.restore
          redirect_to admin_citizens_charters_charters_path, notice: t(".success_html", link: preview_url(@charter, host: current_site.domain))
        end
      end

      private

      def load_charter
        @charter = charters_relation.find(params[:id])
      end

      def charters_relation
        current_site.charters
      end

      def charter_params
        params.require(:charter).permit(
          :service_id,
          :slug,
          :visibility_level,
          title_translations: [*I18n.available_locales]
        )
      end

      def ignored_charter_attributes
        %w(position archived_at created_at updated_at)
      end
    end
  end
end
