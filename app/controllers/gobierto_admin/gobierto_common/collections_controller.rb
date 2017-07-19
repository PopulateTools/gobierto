module GobiertoAdmin
  module GobiertoCommon
    class CollectionsController < BaseController
      helper_method :gobierto_common_collection_preview_url

      def index
        @collections = current_site.collections
        @pages = current_site.pages

        @collection_form = CollectionForm.new(site_id: current_site.id)
      end

      def show
        @collection = find_collection
        @pages = current_site.pages.sort_by_updated_at
      end

      def new
        @collection_form = CollectionForm.new
        @issues = current_site.issues

        render :new_modal, layout: false and return if request.xhr?
      end

      def edit
        @collection = find_collection
        @collection_form = CollectionForm.new(
          @collection.attributes.except(*ignored_collection_attributes)
        )

        render :edit_modal, layout: false and return if request.xhr?
      end

      def create
        @collection_form = CollectionForm.new(collection_params.merge(site_id: current_site.id))

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

      def gobierto_common_collection_preview_url(collection, options = {})
        options[:preview_token] = current_admin.preview_token unless collection.active?
        gobierto_common_collection_url(collection.slug, options)
      end
    end
  end
end
