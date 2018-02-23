# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanTypesController < GobiertoAdmin::GobiertoPlans::BaseController
      def new
        @plan_type_form = PlanTypeForm.new
      end

      def edit
        @plan_type = find_plan_type_by_slug
        @plan_type_form = PlanTypeForm.new(
          @plan_type.attributes.except(*ignored_plan_type_attributes)
        )
      end

      def create
        @plan_type_form = PlanTypeForm.new(plan_type_params)

        if @plan_type_form.save
          track_create_activity

          redirect_to(
            edit_admin_plans_plan_type_path(@plan_type_form.plan_type.slug),
            notice: t(".success")
          )
        else
          render :new
        end
      end

      def update
        @plan_type = find_plan_type
        @plan_type_form = PlanTypeForm.new(
          plan_type_params.merge(id: params[:id])
        )

        if @plan_type_form.save
          track_update_activity

          redirect_to(
            edit_admin_plans_plan_type_path(@plan_type.slug),
            notice: t(".success")
          )
        else
          render :edit
        end
      end

      def destroy
        @plan_type = find_archived_plan_type

        if @plan_type.destroy
          redirect_to admin_plans_path, notice: t(".success")
        else
          redirect_to admin_plans_path, alert: t(".has_items")
        end
      end

      def recover
        @plan_type = find_archived_plan_type
        @plan_type.restore

        redirect_to admin_plans_path, notice: t(".success")
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
          :name,
          :slug
        )
      end

      def ignored_plan_type_attributes
        %w(created_at updated_at archived_at)
      end

      def find_plan_type_by_slug
        ::GobiertoPlans::PlanType.find_by(slug: params[:id])
      end

      def find_plan_type
        ::GobiertoPlans::PlanType.find(params[:id])
      end

      def find_archived_plan_type
        ::GobiertoPlans::PlanType.with_archived.find(params[:plan_type_id] || params[:id])
      end
    end
  end
end
