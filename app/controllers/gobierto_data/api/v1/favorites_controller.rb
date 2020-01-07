# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class FavoritesController < BaseController

        # GET /api/v1/data/resource_type/resource_id/favorites
        # GET /api/v1/data/resource_type/resource_id/favorites.json
        def index
          respond_to do |format|
            format.json do
              render json: filtered_relation.recent, links: links(:index), adapter: :json_api
            end
          end
        end

        # GET /api/v1/data/resource_type/resource_id/user_favorited_queries?user_id=1
        # GET /api/v1/data/resource_type/resource_id/user_favorited_queries.json?user_id=1
        def user_favorited_queries
          find_favorited
          find_user
          respond_to do |format|
            format.json do
              render(
                json: GobiertoData::Query.favorited_by_user(@user, parent: @favorited),
                exclude_relationships: true,
                links: links(:user_favorited_queries),
                adapter: :json_api
              )
            end
          end
        end

        # GET /api/v1/data/resource_type/resource_id/user_favorited_visualizations?user_id=1
        # GET /api/v1/data/resource_type/resource_id/user_favorited_visualizations.json?user_id=1
        def user_favorited_visualizations
          find_favorited
          find_user
          respond_to do |format|
            format.json do
              render(
                json: GobiertoData::Visualization.favorited_by_user(@user, parent: @favorited),
                exclude_relationships: true,
                links: links(:user_favorited_visualizations),
                adapter: :json_api
              )
            end
          end
        end

        # GET /api/v1/data/resource_type/resource_id/favorites/new
        # GET /api/v1/data/resource_type/resource_id/favorites/new.json
        def new
          @item = filtered_relation.new

          render(
            json: @item,
            exclude_links: true,
            links: links(:new),
            adapter: :json_api
          )
        end

        # POST /api/v1/data/resource_type/resource_id/favorites
        # POST /api/v1/data/resource_type/resource_id/favorites.json
        def create
          find_favorited
          @favorite_form = FavoriteForm.new(favorite_params.merge(site_id: current_site.id, favorited: @favorited))

          if @favorite_form.save
            @item = @favorite_form.favorite
            render(
              json: @item,
              status: :created,
              exclude_links: true,
              links: links,
              adapter: :json_api
            )
          else
            api_errors_render(@favorite_form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/data/resource_type/resource_id/favorites/1
        # DELETE /api/v1/data/resource_type/resource_id/favorites/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def base_relation
          if find_favorited.present?
            @favorited.favorites
          else
            GobiertoData::Favorite.none
          end
        end

        def find_favorited
          @favorited = case resource_type
                       when :dataset
                         current_site.datasets.find_by(slug: params[:dataset_slug])
                       when :query
                         current_site.queries.find_by(id: params[:query_id])
                       when :visualization
                         current_site.visualizations.find_by(id: params[:visualization_id])
                       end
        end

        def resource_type
          @resource_type ||= if params.has_key? :dataset_slug
                               :dataset
                             elsif params.has_key? :query_id
                               :query
                             elsif params.has_key? :visualization_id
                               :visualization
                             end
        end

        def favorite_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:user_id])
        end

        def filter_params
          return unless params[:filter].present?

          params.fetch(:filter, {}).permit(:user_id)
        end

        def filtered_relation
          base_relation.where(filter_params)
        end

        def find_item
          @item = filtered_relation.find(params[:id])
        end

        def find_user
          @user = User.find_by(id: params[:user_id])
        end

        def links(self_key = nil)
          return unless resource_type.present?

          {
            index: send("gobierto_data_api_v1_#{resource_type}_favorites_path", filter: filter_params),
            new: send("new_gobierto_data_api_v1_#{resource_type}_favorite_path", filter: filter_params)
          }.tap do |hash|
            if resource_type == :dataset
              hash[:user_favorited_queries] = send("user_favorited_queries_gobierto_data_api_v1_#{resource_type}_favorites_path", user_id: params[:user_id])
            end
            if [:dataset, :query].include? resource_type
              hash[:user_favorited_visualizations] = send("user_favorited_visualizations_gobierto_data_api_v1_#{resource_type}_favorites_path", user_id: params[:user_id])
            end
            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end
      end
    end
  end
end
