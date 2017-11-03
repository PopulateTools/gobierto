module GobiertoAdmin
  module GobiertoCommon
    class CollectionsController < BaseController
      helper_method :gobierto_common_page_preview_url

      before_action :load_collection, only: [:show, :edit, :update]
      before_action :redirect_to_custom_show, only: [:show]

      def show
        @new_item_path = case @collection.item_type
                         when 'GobiertoCms::Page'
                           @pages = ::GobiertoCms::Page.where(id: @collection.pages_in_collection)
                           new_admin_cms_page_path(collection_id: @collection)
                         when 'GobiertoAttachments::Attachment'
                           @file_attachments = ::GobiertoAttachments::Attachment.where(id: @collection.file_attachments_in_collection)
                           new_admin_attachments_file_attachment_path(collection_id: @collection)
                         when 'GobiertoCalendars::Event'
                           @events_presenter = GobiertoAdmin::GobiertoCalendars::EventsPresenter.new(@collection)
                           @events = ::GobiertoCalendars::Event.by_collection(@collection)
                           nil
                         end
      end

      def new
        @collection_form = CollectionForm.new
        @containers = find_containers
        @container_selected = nil
        @types = type_names

        render :new_modal, layout: false and return if request.xhr?
      end

      def edit
        @containers = find_containers
        @container_selected = @collection.container.to_global_id
        @types = type_names
        @type_selected = @collection.item_type

        @collection_form = CollectionForm.new(
          @collection.attributes.except(*ignored_collection_attributes).merge(container_global_id: @collection.container.to_global_id)
        )

        render :edit_modal, layout: false and return if request.xhr?
      end

      def create
        @collection_form = CollectionForm.new(collection_params.merge(site_id: current_site.id))
        @containers = find_containers
        @container_selected = nil
        @types = type_names

        if @collection_form.save
          track_create_activity

          redirect_to(
            admin_common_collection_path(@collection_form.collection),
            notice: t('.success')
          )
        else
          render :new_modal, layout: false and return if request.xhr?
          render :new
        end
      end

      def update
        @collection_form = CollectionForm.new(
          collection_params.merge(id: params[:id])
        )
        @containers = find_containers
        @container_selected = nil
        @types = type_names

        if @collection_form.save
          track_update_activity

          redirect_to(
            admin_common_collection_path(@collection),
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
          :container_global_id,
          :item_type,
          :slug,
          title_translations: [*I18n.available_locales]
        )
      end

      def ignored_collection_attributes
        %w[created_at updated_at container_type container_id]
      end

      def container_items
        [current_site, current_site.people, current_site.processes].flatten
      end

      def find_containers
        @containers ||= container_items.map { |item| ["#{item.class.model_name.human}: #{item}", item.to_global_id] }
      end

      def type_names
        ::GobiertoCommon::Collection.type_classes(params["item_type"])
      end

      def gobierto_common_page_preview_url(page, options = {})
        options.merge!(preview_token: current_admin.preview_token) unless page.active?
        gobierto_cms_page_url(page.slug, options)
      end

      def load_collection
        @collection = current_site.collections.find(params[:id])
      end

      def redirect_to_custom_show
        case @collection.item_type
          when 'GobiertoCms::Page'
            if @collection.container.is_a?(::GobiertoParticipation::Process)
              redirect_to admin_participation_process_pages_path(@collection.container) and return false
            end
          when 'GobiertoAttachments::Attachment'
            if @collection.container.is_a?(::GobiertoParticipation::Process)
              redirect_to admin_participation_process_file_attachments_path(@collection.container) and return false
            end
          when 'GobiertoCalendars::Event'
            if @collection.container.is_a?(::GobiertoPeople::Person)
              redirect_to admin_people_person_events_path(@collection.container) and return false
            elsif @collection.container.is_a?(::GobiertoParticipation::Process)
              redirect_to admin_participation_process_events_path(@collection.container) and return false
            end
        end
      end
    end
  end
end
