# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    module Api
      class CategoriesController < BaseController
        def index
          @plan = current_site.plans.find params[:plan_id]
          @categories = @plan.categories.sorted
          render json: @categories, each_serializer: GobiertoAdmin::GobiertoPlans::CategorySerializer
        end
      end
    end
  end
end
