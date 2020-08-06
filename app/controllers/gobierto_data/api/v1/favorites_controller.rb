# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class FavoritesController < BaseController

        skip_before_action :authenticate_user_in_site, except: [:index]
        before_action :authenticate_user!, except: [:index]
        before_action :allow_author!, only: [:destroy]

        # GET /api/v1/data/resource_type/resource_id/favorites
        # GET /api/v1/data/resource_type/resource_id/favorites.json
        def index
          respond_to do |format|
            format.json do
              render(
                json: user_favorites,
                exclude_relationships: true,
                links: links(:index),
                adapter: :json_api,
                meta: {
                  self_favorited: user_favorites.exists?(favorited: @favorited)
                }.tap do |meta|
                  [:dataset, :query].each do |res_type|
                    meta["#{res_type}_favorited"] = @user.data_favorites.exists?(favorited: @favorited.send(res_type)) if @favorited.respond_to?(res_type)
                  end
                end
              )
            end
          end
        end

        # POST /api/v1/data/resource_type/resource_id/favorites
        # POST /api/v1/data/resource_type/resource_id/favorites.json
        def create
          find_favorited
          @favorite_form = FavoriteForm.new(site_id: current_site.id, favorited: @favorited, user_id: current_user.id)

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
                         current_site.datasets.send(valid_preview_token? ? :itself : :active).find_by(slug: params[:dataset_slug])
                       when :query
                         current_site.queries.send(valid_preview_token? ? :itself : :active).find_by(id: params[:query_id])
                       when :visualization
                         current_site.visualizations.send(valid_preview_token? ? :itself : :active).find_by(id: params[:visualization_id])
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

        def filter_params
          return unless params[:filter].present?

          params.fetch(:filter, {}).permit(:user_id)
        end

        def filtered_relation
          base_relation.where(filter_params)
        end

        def find_item
          @item = filtered_relation.find_by(user_id: current_user.id)
        end

        def find_user
          @user = current_site.users.find_by(id: filter_params&.dig(:user_id)) || current_user
        end

        def links(self_key = nil)
          return unless resource_type.present?

          {
            index: send("gobierto_data_api_v1_#{resource_type}_favorites_path", filter: filter_params)
          }.tap do |hash|
            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end

        def allow_author!
          render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) && return unless find_item
        end

        def user_favorites
          @user_favorites ||= begin
                                find_favorited
                                find_user
                                return GobiertoData::Favorite.none unless @user.present?

                                user_favs = @user.data_favorites
                                case resource_type

                                when :dataset
                                  user_favs.where(
                                    favorited: @favorited.visualizations
                                  ).or(
                                    user_favs.where(
                                      favorited: @favorited.queries
                                    ).or(
                                      user_favs.where(
                                        favorited: @favorited
                                      )
                                    )
                                  ).order(favorited_type: :asc).recent
                                when :query
                                  user_favs.where(
                                    favorited: @favorited.visualizations
                                  ).or(
                                    user_favs.where(
                                      favorited: @favorited
                                    )
                                  ).order(favorited_type: :asc).recent
                                else
                                  user_favs.where(favorited: @favorited)
                                end
                              end
        end
      end
    end
  end
end
