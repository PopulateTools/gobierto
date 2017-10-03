# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class PagesController < BaseController
      def index
        @collections = current_site.collections.by_item_type("GobiertoCms::Page")
        @pages = ::GobiertoCms::Page.pages_in_collections(current_site).sort_by_updated_at(10)
      end

      def new
        @collection = find_collection(params[:collection_id])
        @page_form = PageForm.new(site_id: current_site.id, collection_id: @collection.id)
        @page_visibility_levels = get_page_visibility_levels
      end

      def edit
        @page = find_page
        @collection = @page.collection
        @page_visibility_levels = get_page_visibility_levels
        @page_form = PageForm.new(
          @page.attributes.except(*ignored_page_attributes).merge(collection_id: @collection.id)
        )
      end

      def create
        @collection = find_collection(params[:page][:collection_id])
        @page_form = PageForm.new(page_params.merge(site_id: current_site.id, admin_id: current_admin.id, collection_id: @collection.id))

        if @page_form.save
          @collection.append(@page_form.page)

          redirect_to(
            edit_admin_cms_page_path(@page_form.page.id, collection_id: @collection.id),
            notice: t(".success_html", link: gobierto_cms_page_preview_url(@page_form.page, host: current_site.domain))
          )
        else
          @page_visibility_levels = get_page_visibility_levels
          render :edit
        end
      end

      def update
        @page = find_page
        @page_form = PageForm.new(page_params.merge(id: @page.id, admin_id: current_admin.id, site_id: current_site.id))

        if @page_form.save

          redirect_to(
            edit_admin_cms_page_path(@page_form.page.id),
            notice: t(".success_html", link: gobierto_cms_page_preview_url(@page_form.page, host: current_site.domain))
          )
        else
          @page_visibility_levels = get_page_visibility_levels
          render :edit
        end
      end

      def destroy
        @page = find_page
        @page.destroy

        redirect_to admin_cms_pages_path, notice: t(".success")
      end

      private

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def get_page_visibility_levels
        ::GobiertoCms::Page.visibility_levels
      end

      def page_params
        params.require(:page).permit(
          :visibility_level,
          :attachment_ids,
          :collection_id,
          :slug,
          title_translations: [*I18n.available_locales],
          body_translations:  [*I18n.available_locales]
        )
      end

      def ignored_page_attributes
        %w(created_at updated_at title body)
      end

      def find_page
        current_site.pages.find(params[:id])
      end

      def find_collection(collection_id)
        ::GobiertoCommon::Collection.find_by(id: collection_id)
      end
    end
  end
end
