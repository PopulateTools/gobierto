# frozen_string_literal: true

module GobiertoPlans
  module Api
    # class PlanProjectsController < GobiertoPlans::ApplicationController
    class PlanProjectsController < ApiBaseController
      include ::PreviewTokenHelper
      include User::SessionHelper

      # respond_to :json
      def index
        @plan = find_plan
        @category = @plan.categories.find(params[:category_id])

        render json: GobiertoPlans::CategoryTermDecorator.new(@category, plan: @plan, vocabulary: @plan.categories_vocabulary, site: current_site).nodes_data
      end

      private

      def find_plan
        valid_preview_token? ? current_site.plans.find(params[:plan_id]) : current_site.plans.published.find(params[:plan_id])
      end
    end
  end
end
