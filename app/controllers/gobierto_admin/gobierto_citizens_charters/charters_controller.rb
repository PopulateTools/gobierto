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
        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(site_id: current_site.id, item: @charter_form.resource)
        render(:new_modal, layout: false) && return if request.xhr?
      end

      def edit
        load_charter

        @charter_form = CharterForm.new(
          @charter.attributes.except(*ignored_charter_attributes).merge(site_id: current_site.id)
        )
        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(site_id: current_site.id, item: @charter)
        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def create
        @charter_form = CharterForm.new(charter_params.merge(site_id: current_site.id))

        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(site_id: current_site.id, item: @charter_form.resource)
        @custom_fields_form.custom_field_records = custom_params

        if @charter_form.save
          @custom_fields_form.save
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
        load_charter

        @charter_form = CharterForm.new(charter_params.merge(id: params[:id], site_id: current_site.id))
        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(site_id: current_site.id, item: @charter)
        @custom_fields_form.custom_field_records = custom_params

        if @charter_form.save && @custom_fields_form.save
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
          @charter.restore(recursive: true)
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

      def custom_params
        params.require(self.class.name.demodulize.gsub("Controller", "").underscore.singularize).permit(custom_records: {})
      end

      def ignored_charter_attributes
        %w(position archived_at created_at updated_at)
      end

      def preview_url(charter, options = {})
        options[:preview_token] = current_admin.preview_token unless charter.active?
        gobierto_citizens_charters_service_charter_url(charter.service.slug, charter.slug, options)
      end
    end
  end
end
