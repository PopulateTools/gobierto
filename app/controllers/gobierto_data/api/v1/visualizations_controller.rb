# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class VisualizationsController < BaseController
        include ::GobiertoCommon::SortableApi

        before_action :authenticate_user!, except: [:index, :show, :new]
        before_action :allow_author!, only: [:update, :destroy]

        sortable_attributes :created_at, :updated_at

        # GET /api/v1/data/visualizations
        # GET /api/v1/data/visualizations.json
        # GET /api/v1/data/visualizations.csv
        # GET /api/v1/data/visualizations.xlsx
        def index
          respond_to do |format|
            format.json do
              render json: filtered_relation, links: links(:index), adapter: :json_api
            end

            format.csv do
              render_csv(csv_from_relation(filtered_relation, csv_options_params))
            end

            format.xlsx do
              send_data xlsx_from_relation(filtered_relation, name: controller_name.titleize).read, filename: "#{controller_name.underscore}.xlsx"
            end
          end
        end

        # GET /api/v1/data/visualizations/1
        # GET /api/v1/data/visualizations/1.json
        def show
          find_item

          render(
            json: @item,
            exclude_links: true,
            links: links(:show),
            adapter: :json_api
          )
        end

        # GET /api/v1/data/visualizations/new
        # GET /api/v1/data/visualizations/new.json
        def new
          @item = base_relation.model.new(name_translations: available_locales_hash, user: current_user)

          render(
            json: @item,
            exclude_links: true,
            with_translations: true,
            links: links(:new),
            adapter: :json_api
          )
        end

        # POST /api/v1/data/visualizations
        # POST /api/v1/data/visualizations.json
        def create
          @visualization_form = VisualizationForm.new(visualization_params.merge(site_id: current_site.id, user_id: current_user.id))

          if @visualization_form.save
            @item = @visualization_form.visualization
            render(
              json: @item,
              status: :created,
              exclude_links: true,
              with_translations: true,
              links: links(:show),
              adapter: :json_api
            )
          else
            api_errors_render(@visualization_form, adapter: :json_api)
          end
        end

        # PUT /api/v1/data/visualizations/1
        # PUT /api/v1/data/visualizations/1.json
        def update
          @visualization_form = VisualizationForm.new(visualization_params.except(*ignored_attributes_on_update).merge(site_id: current_site.id, id: @item.id))

          if @visualization_form.save
            render(
              json: @visualization_form.visualization,
              exclude_links: true,
              with_translations: true,
              links: links,
              adapter: :json_api
            )
          else
            api_errors_render(@visualization_form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/data/visualizations/1
        # DELETE /api/v1/data/visualizations/1.json
        def destroy
          @item.destroy

          head :no_content
        end

        private

        def base_relation
          if find_dataset.present?
            @dataset.visualizations.open
          elsif find_query.present?
            @query.visualizations.open
          else
            current_site.visualizations.send(valid_preview_token? ? :itself : :active).open
          end
        end

        def find_query
          @query = current_site.queries.send(valid_preview_token? ? :itself : :active).find_by(id: params[:query_id])
        end

        def find_dataset
          @dataset = current_site.datasets.send(valid_preview_token? ? :itself : :active).find_by(id: params[:dataset_id])
        end

        def visualization_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: writable_attributes).tap do |post_params|
            post_params[:spec] = raw_spec_from_params if post_params.has_key?(:spec)
          end
        end

        def raw_spec_from_params
          JSON.parse(request.raw_post).dig("data", "attributes", "spec")
        end

        def writable_attributes
          [:query_id, :dataset_id, :name_translations, :name, :privacy_status, :spec, :sql]
        end

        def filter_params
          params.fetch(:filter, {}).permit(:user_id, :dataset_id, :query_id)
        end

        def filtered_relation
          if user_authenticated? && (filter_params[:user_id].nil? || filter_params[:user_id].to_i == current_user.id)
            base_relation.where(filter_params).or(
              base_relation.unscope(where: :privacy_status).where(filter_params.merge(user_id: current_user.id))
            ).order(order_params)
          else
            base_relation.where(filter_params).order(order_params)
          end
        end

        def find_item
          @item = base_relation.unscope(where: :privacy_status).find(params[:id])
        end

        def links(self_key = nil)
          id = @item&.id
          {
            index: gobierto_data_api_v1_visualizations_path(filter: filter_params),
            new: new_gobierto_data_api_v1_visualization_path
          }.tap do |hash|
            if id.present?
              hash.merge!(
                show: gobierto_data_api_v1_visualization_path(id)
              )
            end

            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end

        def ignored_attributes_on_update
          [:query_id, :user_id]
        end

        def allow_author!
          find_item
          render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) && return if @item.user != current_user
        end
      end
    end
  end
end
