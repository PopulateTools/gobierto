# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class ServicesController < GobiertoCitizensCharters::BaseController
      def index
        @services = current_site.services
        @archived_services = current_site.services.only_archived
      end

      def new
        @service_form = ServiceForm.new(site_id: current_site.id)
        render(:new_modal, layout: false) && return if request.xhr?
      end

      def edit
        load_service

        @service_form = ServiceForm.new(
          @service.attributes.except(*ignored_service_attributes).merge(site_id: current_site.id)
        )
        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def create
        @service_form = ServiceForm.new(service_params.merge(site_id: current_site.id))

        if @service_form.save
          redirect_to(
            admin_citizens_charters_services_path,
            notice: t(".success_html", link: preview_url(@service_form.resource, host: current_site.domain))
          ) && return
        else
          render(:new_modal, layout: false) && return if request.xhr?
          render :new
        end
      end

      def update
        @service_form = ServiceForm.new(service_params.merge(id: params[:id], site_id: current_site.id))

        if @service_form.save
          redirect_to(
            admin_citizens_charters_services_path,
            notice: t(".success_html", link: preview_url(@service_form.resource, host: current_site.domain))
          ) && return
        else
          render(:edit_modal, layout: false) && return if request.xhr?
          render :edit
        end
      end

      def destroy
        load_service

        if @service.destroy
          redirect_to admin_citizens_charters_services_path, notice: t(".success")
        else
          redirect_to admin_citizens_charters_services_path, alert: t(".destroy_failed")
        end
      end

      def recover
        @service = current_site.services.only_deleted.find(params[:service_id])
        @service.restore
        redirect_to admin_citizens_charters_services_path, notice: t(".success_html", link: preview_url(@service, host: current_site.domain))
      end

      private

      def load_service
        @service = current_site.services.find(params[:id])
      end

      def service_params
        params.require(:service).permit(
          :category_id,
          :slug,
          :visibility_level,
          title_translations: [*I18n.available_locales]
        )
      end

      def ignored_service_attributes
        %w(archived_at created_at position updated_at site_id)
      end
    end
  end
end
