# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanTypesController < GobiertoAdmin::GobiertoPlans::BaseController
      def index
        @plan_types = ::GobiertoPlans::PlanType.all.sort_by_updated_at
      end

      def new
        @plan_type_form = PlanTypeForm.new(site_id: current_site.id)
      end

      def edit
        @plan_type = find_plan_type
        @plan_type_form = PlanTypeForm.new(
          @plan_type.attributes.except(*ignored_plan_type_attributes).merge(site_id: current_site.id)
        )
      end

      def create
        @plan_type_form = PlanTypeForm.new(plan_type_params.merge(site_id: current_site.id))

        if @plan_type_form.save
          track_create_activity

          redirect_to(
            edit_admin_plans_plan_type_path(@plan_type_form.plan_type),
            notice: t(".success")
          )
        else
          render :new
        end
      end

      def update
        @plan_type = find_plan_type
        @plan_type_form = PlanTypeForm.new(
          plan_type_params.merge(id: params[:id], site_id: current_site.id)
        )

        if @plan_type_form.save
          track_update_activity

          redirect_to(
            edit_admin_plans_plan_type_path(@plan_type),
            notice: t(".success")
          )
        else
          render :edit
        end
      end

      def destroy
        @plan_type = find_plan_type

        if @plan_type.destroy
          redirect_to admin_plans_plan_types_path, notice: t(".success")
        else
          redirect_to admin_plans_plan_types_path, alert: t(".has_items")
        end
      end

      private

      def track_create_activity
        Publishers::GobiertoPlansPlanTypeActivity.broadcast_event("plan_type_created", default_activity_params.merge(subject: @plan_type_form.plan_type))
      end

      def track_update_activity
        Publishers::GobiertoPlansPlanTypeActivity.broadcast_event("plan_type_updated", default_activity_params.merge(subject: @plan_type))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def plan_type_params
        params.require(:plan_type).permit(
          :slug,
          name_translations: [*I18n.available_locales]
        )
      end

      def ignored_plan_type_attributes
        %w(created_at updated_at site_id)
      end

      def find_plan_type_by_slug
        current_site.plan_types.find_by(slug: params[:id])
      end

      def find_plan_type
        current_site.plan_types.find(params[:id])
      end
    end
  end
end
