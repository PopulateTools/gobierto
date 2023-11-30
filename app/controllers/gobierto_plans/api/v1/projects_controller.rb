# frozen_string_literal: true

module GobiertoPlans
  module Api
    module V1
      class ProjectsController < BaseController
        include ::GobiertoCommon::CustomFieldsApi
        include ::GobiertoCommon::SecuredWithAdminToken

        skip_before_action :set_admin_with_token, only: [:index, :show]

        # GET /api/v1/plans/1/projects
        # GET /api/v1/plans/1/projects.json
        def index
          json = cache_service.fetch("#{filtered_relation.cache_key_with_version}/#{@plan.cache_key}/#{I18n.locale}/projects_collection") do
            render_to_string(
              json: filtered_relation,
              links: links(:index),
              each_serializer: GobiertoPlans::NodeSerializer,
              plan: @plan,
              custom_fields: custom_fields,
              preloaded_data: transformed_custom_field_record_values(filtered_relation),
              versions_indexes: filtered_relation.versions_indexes,
              category_ids: category_ids,
              adapter: :json_api
            )
          end
          render json: json
        end

        # GET /api/v1/plans/1/projects/1
        # GET /api/v1/plans/1/projects/1.json
        def show
          find_item

          render(
            json: @item,
            serializer: ::GobiertoPlans::NodeSerializer,
            plan: @plan,
            custom_fields: custom_fields,
            preloaded_data: transformed_custom_field_record_values(filtered_relation),
            versions_indexes: filtered_relation.versions_indexes,
            category_ids: category_ids,
            adapter: :json_api
          )
        end

        # GET /api/v1/plans/1/projects/new
        # GET /api/v1/plans/1/projects/new.json
        def new
          render(
            json: base_relation.new(name_translations: available_locales_hash),
            serializer: ::GobiertoPlans::ApiNodeSerializer,
            plan: @plan,
            adapter: :json_api
          )
        end

        # POST /api/v1/plans/1/projects
        # POST /api/v1/plans/1/projects.json
        def create
          find_plan

          @form = GobiertoAdmin::GobiertoPlans::ProjectsForm.new(plan_id: @plan.id, site_id: current_site.id, admin: current_admin).project_form(project_params)

          if @form.save
            project = @form.project

            render(
              json: project,
              serializer: ::GobiertoPlans::ApiNodeSerializer,
              plan: @plan,
              status: :created,
              adapter: :json_api
            )
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        # PUT /api/v1/plans/1/projects/1
        # PUT /api/v1/plans/1/projects/1.json
        def update
          find_item

          @form = GobiertoAdmin::GobiertoPlans::ProjectsForm.new(plan_id: @plan.id, site_id: current_site.id, admin: current_admin).project_form(project_params.merge(id: @item.id))

          if @form.save
            project = @form.project

            render(
              json: project,
              serializer: ::GobiertoPlans::ApiNodeSerializer,
              plan: @plan,
              status: :created,
              adapter: :json_api
            )
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/plans/1/projects/1
        # DELETE /api/v1/plans/1/projects/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def base_relation
          find_plan

          @plan.nodes.published
        end

        def category_ids
          filtered_relation.select("gplan_nodes.id", "gplan_categories_nodes.category_id").map { |project| [project.id, project.category_id] }.to_h
        end

        def custom_fields
          @custom_fields ||= @plan.front_available_custom_fields
        end

        def find_plan
          @plan = current_site.plans.send(valid_preview_token? ? :itself : :published).find_by(id: params[:plan_id])
        end

        def find_item
          @item = base_relation.find(params[:id])
        end

        def project_params
          @project_params ||= ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: project_attributes)
        end

        def project_attributes
          @project_attributes ||= GobiertoAdmin::GobiertoPlans::ProjectsForm::WRITABLE_ATTRIBUTES + [:category_external_id, :status_external_id]
        end

        def available_locales_hash
          @available_locales_hash ||= available_locales.each_with_object({}) { |key, locales| locales[key] = nil }
        end

        def available_locales
          @available_locales ||= current_site.configuration.available_locales
        end

        def links(self_key = nil)
          {
            index: gobierto_plans_api_v1_plan_projects_path(filter: filter_params)
          }.tap do |hash|
            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end
      end
    end
  end
end
