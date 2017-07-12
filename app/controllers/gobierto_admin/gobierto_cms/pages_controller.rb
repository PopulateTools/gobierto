module GobiertoAdmin
  module GobiertoCms
    class PagesController < BaseController

      before_action { module_enabled!(current_site, "GobiertoCms") }
      before_action { module_allowed!(current_admin, "GobiertoCms") }

      helper_method :gobierto_cms_page_preview_url

      def index
        @pages = current_site.pages.sorted
      end

      def new
        @page_form = PageForm.new(site_id: current_site.id)
        @page_visibility_levels = get_page_visibility_levels
      end

      def edit
        @page = find_page
        @page_visibility_levels = get_page_visibility_levels
        @page_form = PageForm.new(
          @page.attributes.except(*ignored_page_attributes)
        )
      end

      def create
        @page_form = PageForm.new(page_params.merge(site_id: current_site.id))

        if @page_form.save
          track_create_activity

          redirect_to(
            edit_admin_cms_page_path(@page_form.page.id),
            notice: t(".success_html", link: gobierto_cms_page_preview_url(@page_form.page, host: current_site.domain))
          )
        else
          @page_visibility_levels = get_page_visibility_levels
          render :new
        end
      end

      def update
        @page = find_page
        @page_form = PageForm.new(page_params.merge(id: @page.id, site_id: current_site.id))

        if @page_form.save
          track_update_activity

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
        track_destroy_activity

        redirect_to admin_cms_pages_path, notice: t(".success")
      end

      private

      def track_create_activity
        Publishers::GobiertoCmsPageActivity.broadcast_event("page_created", default_activity_params.merge({subject: @page_form.page}))
      end

      def track_update_activity
        Publishers::GobiertoCmsPageActivity.broadcast_event("page_updated", default_activity_params.merge({subject: @page}))
      end

      def track_destroy_activity
        Publishers::GobiertoCmsPageActivity.broadcast_event("page_deleted", default_activity_params.merge({subject: @page}))
      end

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
          title_translations: [*I18n.available_locales],
          body_translations:  [*I18n.available_locales],
          slug_translations:  [*I18n.available_locales],
        )
      end

      def ignored_page_attributes
        %w( created_at updated_at title body slug )
      end

      def find_page
        current_site.pages.find(params[:id])
      end

      def gobierto_cms_page_preview_url(page, options = {})
        options.merge!(preview_token: current_admin.preview_token) unless page.active?
        gobierto_cms_page_url(page.slug, options)
      end
    end
  end
end
