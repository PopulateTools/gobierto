# frozen_string_literal: true

module GobiertoPlans
  module Api
    module V1
      class PlansController < BaseController

        include ::GobiertoCommon::CustomFieldsApi
        include ::GobiertoCommon::SecuredWithAdminToken

        skip_before_action :set_admin_with_token, only: [:index, :show, :meta]

        def vocabularies_adapter
          :json_api
        end

        # GET /api/v1/plans
        # GET /api/v1/plans.json
        def index
          return unless stale? filtered_relation

          render(
            json: filtered_relation,
            links: links(:index),
            each_serializer: GobiertoPlans::PlanSerializer,
            adapter: :json_api,
            with_translations: false,
            exclude_links: false,
            exclude_relationships: true
          )
        end

        # GET /api/v1/plans/1
        # GET /api/v1/plans/1.json
        def show
          find_resource

          render(
            json: @resource,
            serializer: GobiertoPlans::PlanSerializer,
            adapter: :json_api,
            with_translations: false,
            exclude_links: false,
            exclude_relationships: false,
            vocabularies_adapter: :json_api
          )
        end

        # GET /api/v1/plans/1/admin
        # GET /api/v1/plans/1/admin.json
        def admin
          @resource = current_site.plans.find(params[:id])

          render(
            json: @resource,
            serializer: GobiertoPlans::ApiPlanSerializer,
            adapter: :json_api,
            with_translations: false,
            exclude_links: false,
            exclude_relationships: false,
            vocabularies_adapter: :json_api
          )
        end

        # PUT /api/v1/plans/1/admin
        # PUT /api/v1/plans/1/admin.json
        def update
          find_resource

          form_params = plan_params.merge(site_id: current_site.id, id: @resource.id)
          form_params.merge!(plan_type_id: @resource.plan_type_id) unless plan_params.has_key?(:plan_type_id)

          @form = GobiertoAdmin::GobiertoPlans::PlanForm.new(form_params)
          if @form.save
            @resource = @form.plan
            create_or_update_projects(@resource, projects_params) do
              render(
                json: @resource,
                serializer: GobiertoPlans::ApiPlanSerializer,
                adapter: :json_api,
                with_translations: false,
                exclude_links: false,
                exclude_relationships: false,
                vocabularies_adapter: :json_api
              )
            end
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        private

        def create_or_update_projects(plan, projects_data)
          if projects_data.blank?
            yield(plan)
          else
            @projects_form = GobiertoAdmin::GobiertoPlans::ProjectsForm.new(projects: projects_data, site_id: current_site.id, plan_id: plan.id, admin: current_admin)
            if @projects_form.save
              yield(plan)
            else
              api_errors_render(@projects_form, adapter: :json_api)
            end
          end
        end

        def base_relation
          if params[:id].present?
            find_resource
            @resource.nodes.unscope(:order)
          else
            plans_base_relation
          end
        end

        def plans_base_relation
          @plans_base_relation = current_site.plans.send(valid_preview_token? ? :itself : :published)
        end

        def plan_params
          @plan_params ||= ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: writable_attributes).tap do |p|
            unless p[:configuration_data].is_a?(String)
              p[:configuration_data] = p[:configuration_data].blank? ? @resource.attributes["configuration_data"] : p[:configuration_data].to_json
            end
            writable_attributes.each do |attr|
              p[attr] = @resource.send(attr) unless @resource.blank? || p.has_key?(attr)
            end
          end
        end

        def projects_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:projects])[:projects]
        end

        def writable_attributes
          [:slug, :title_translations, :introduction_translations, :configuration_data, :year, :visibility_level, :css, :footer_translations, :plan_type_id]
        end

        def find_resource
          @resource = plans_base_relation.find(params[:id])
        end

        def custom_fields
          @custom_fields ||= find_resource.front_available_custom_fields
        end

        def links(self_key = nil)
          id = @resource&.id
          {
            index: gobierto_plans_api_v1_plans_path(filter: filter_params)
          }.tap do |hash|
            if id.present?
              hash.merge!(
                show: gobierto_plans_api_v1_plan_path(id),
                metadata: meta_gobierto_plans_api_v1_plan(id)
              )
            end

            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end
      end
    end
  end
end
