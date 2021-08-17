# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class PagesController < BaseController
      include CustomFieldsHelper

      before_action :load_collection, only: [:new, :edit, :create, :update]
      before_action :load_site_attachments_collection, only: [:new, :edit, :create, :update]

      def index
        @sections = current_site.sections
        @collections = current_site.collections.by_item_type(["GobiertoCms::Page", "GobiertoCms::News"])
        @pages = ::GobiertoCms::Page.in_collections(current_site).sort_by_published_on.limit(10)
      end

      def new
        @page_form = PageForm.new(site_id: current_site.id, collection_id: @collection.id)
        @page_visibility_levels = get_page_visibility_levels
        @section_id = nil
        @parent_id = nil
        initialize_custom_field_form
      end

      def edit
        load_page(preview: true)
        @section_id = @page.section_id
        @parent_id = @page.parent_id
        @page_section_item_id = ::GobiertoCms::SectionItem.find_by(item_id: @page.id).try(:id)

        @page_visibility_levels = get_page_visibility_levels
        @page_form = PageForm.new(
          @page.attributes.except(*ignored_page_attributes).merge(collection_id: @collection)
        )
        initialize_custom_field_form
      end

      def create
        @page_form = PageForm.new(page_params.merge(site_id: current_site.id, admin_id: current_admin.id, collection_id: @collection))
        initialize_custom_field_form

        if @page_form.save
          custom_fields_save
          track_create_activity

          redirect_to(
            edit_admin_cms_page_path(@page_form.page.id, collection_id: @collection.id),
            notice: t(".success_html", link: gobierto_cms_page_preview_path(@page_form.page))
          )
        else
          @page_visibility_levels = get_page_visibility_levels
          render :edit
        end
      end

      def update
        load_page(preview: true)
        @page_form = PageForm.new(page_params.merge(id: @page.id, admin_id: current_admin.id, site_id: current_site.id, collection_id: @collection.id))
        initialize_custom_field_form

        if @page_form.save && custom_fields_save
          track_update_activity

          redirect_to(
            edit_admin_cms_page_path(@page_form.page.id, collection_id: @collection),
            notice: t(".success_html", link: gobierto_cms_page_preview_path(@page_form.page))
          )
        else
          @page_visibility_levels = get_page_visibility_levels
          render :edit
        end
      end

      def destroy
        load_page
        process = find_process if params[:process_id]

        redirect_path = if process
                          admin_participation_process_pages_path(process_id: process)
                        else
                          admin_common_collection_path(@page.collection)
                        end

        if @page.destroyable?
          @page.destroy
          redirect_to redirect_path, notice: t(".success")
        else
          redirect_to redirect_path, alert: destroy_error_message
        end
      end

      def recover
        @page = find_archived_page
        @page.restore

        process = find_process if params[:process_id]

        if process
          redirect_to admin_participation_process_pages_path(process_id: process), notice: t(".success")
        else
          redirect_to admin_common_collection_path(@page.collection), notice: t(".success")
        end
      end

      private

      def load_collection
        @collection = current_site.collections.find(params[:collection_id])
      end

      def load_site_attachments_collection
        @site_attachments_collection = current_site.collections.find_by!(container: current_site, item_type: "GobiertoAttachments::Attachment")
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def get_page_visibility_levels
        ::GobiertoCms::Page.visibility_levels
      end

      def track_create_activity
        Publishers::GobiertoCmsPageActivity.broadcast_event("page_created", default_activity_params.merge(subject: @page_form.page))
      end

      def track_update_activity
        Publishers::GobiertoCmsPageActivity.broadcast_event("page_updated", default_activity_params.merge(subject: @page))
      end

      def page_params
        params.require(:page).permit(
          :visibility_level,
          :attachment_ids,
          :collection_id,
          :slug,
          :section,
          :parent,
          :published_on,
          title_translations: [*I18n.available_locales],
          body_translations:  [*I18n.available_locales],
          body_source_translations: [*I18n.available_locales]
        )
      end

      def ignored_page_attributes
        %w(created_at updated_at title body collection_id archived_at)
      end

      def load_page(opts = {})
        @page = current_site.pages.find(params[:id])
        @preview_item = @page if opts[:preview]
      end

      def find_page
        current_site.pages.find(params[:id])
      end

      def find_process
        current_site.processes.find(params[:process_id])
      end

      def find_archived_page
        current_site.pages.with_archived.find(params[:page_id])
      end

      def find_collection(collection_id)
        ::GobiertoCommon::Collection.find_by(id: collection_id)
      end

      def destroy_error_message
        associated_items_html = @page.process_stage_pages.map do |stage_page|
          edit_page_path = edit_admin_participation_process_process_stage_process_stage_page_path(
            stage_page,
            process_id: stage_page.process.id,
            process_stage_id: stage_page.process_stage
          )
          "<a href='#{edit_page_path}'>#{stage_page.process.title}</a>"
        end.join(", ").html_safe

        t("gobierto_admin.gobierto_cms.pages.destroy.error_associated_items", links: associated_items_html).html_safe
      end

      def initialize_custom_field_form
        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(
          site_id: current_site.id,
          item: @page,
          instance: @collection
        )
        custom_params_key = self.class.name.demodulize.gsub("Controller", "").underscore.singularize
        return if request.get? || !params.has_key?(custom_params_key)

        @custom_fields_form.custom_field_records = params.require(custom_params_key).permit(custom_records: {})
      end
    end
  end
end
