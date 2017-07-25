module GobiertoAdmin
  module GobiertoCommon
    class CollectionsController < BaseController
      helper_method :gobierto_common_page_preview_url

      def index
        @collections = current_site.collections.by_item_type('GobiertoCms::Page')
        @pages = current_site.pages

        @collection_form = CollectionForm.new(site_id: current_site.id)
      end

      def show
        @collection = find_collection
        @pages = ::GobiertoCms::Page.where(id: @collection.pages_in_collection)
      end

      def new
        @collection_form = CollectionForm.new
        @issues = current_site.issues
        @site = Site.where(id: current_site.id)
        @containers = container_names_new
        @container_selected = nil

        render :new_modal, layout: false and return if request.xhr?
      end

      def edit
        @collection = find_collection
        @issues = current_site.issues
        @site = Site.where(id: current_site.id)
        @containers = container_names_edit
        @container_selected = @collection.container_id

        @collection_form = CollectionForm.new(
          @collection.attributes.except(*ignored_collection_attributes)
        )

        render :edit_modal, layout: false and return if request.xhr?
      end

      def create
        @collection_form = CollectionForm.new(collection_params.merge(site_id: current_site.id))
        @issues = current_site.issues
        @site = Site.where(id: current_site.id)
        @containers = container_names_new
        @container_selected = nil

        if @collection_form.save
          track_create_activity

          redirect_to(
            admin_common_collections_path(@collection),
            notice: t('.success')
          )
        else
          render :new_modal, layout: false and return if request.xhr?
          render :new
        end
      end

      def update
        @collection = find_collection
        @collection_form = CollectionForm.new(
          collection_params.merge(id: params[:id])
        )
        @issues = current_site.issues
        @site = Site.where(id: current_site.id)
        @containers = container_names_new
        @container_selected = nil

        if @collection_form.save
          track_update_activity

          redirect_to(
            admin_common_collections_path(@collection),
            notice: t('.success')
          )
        else
          render :edit_modal, layout: false and return if request.xhr?
          render :edit
        end
      end

      private

      def track_create_activity
        Publishers::GobiertoCommonCollectionActivity.broadcast_event('collection_created', default_activity_params.merge(subject: @collection_form.collection))
      end

      def track_update_activity
        Publishers::GobiertoCommonCollectionActivity.broadcast_event('collection_updated', default_activity_params.merge(subject: @collection))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def collection_params
        params.require(:collection).permit(
          :container_id,
          :container_type,
          :item_type,
          :slug,
          title_translations: [*I18n.available_locales]
        )
      end

      def ignored_collection_attributes
        %w[created_at updated_at]
      end

      def find_collection
        current_site.collections.find(params[:id])
      end

      def container_names_new
        @site.map { |x| ["Site: #{x.location_name}", x.to_global_id] } +
          @issues.map { |x| ["Issue: #{x.name}", x.to_global_id] }
      end

      def container_names_edit
        @site.map { |x| ["Site: #{x.location_name}", x.id] } +
          @issues.map { |x| ["Issue: #{x.name}", x.id] }
      end

      def gobierto_common_page_preview_url(page, options = {})
        options.merge!(preview_token: current_admin.preview_token) unless page.active?
        gobierto_cms_page_url(page.slug, options)
      end
    end
  end
end
