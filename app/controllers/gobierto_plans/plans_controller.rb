# frozen_string_literal: true

module GobiertoPlans
  class PlansController < GobiertoPlans::ApplicationController
    include User::SessionHelper

    before_action :load_plans, only: [:index, :show]

    def index
      # TODO: Pending adaptation to new plans
      plan = current_site.plans.first
      redirect_to gobierto_plans_plan_path(id: plan.slug)
    end

    def show
      @plan = find_plan
      @levels = @plan.categories.maximum("level")
      plan_tree = plan_tree(@plan.categories.where(parent_id: 0))

      respond_to do |format|
        format.html
        format.json do
          render(
            json: { plan_tree: plan_tree.to_json }
          )
        end
      end
    end

    private

    def find_plan
      current_site.plans.find_by!(slug: params[:id])
    end

    def load_plans
      @plans = current_site.plans
    end

    def plan_tree(categories, tree = [])
      categories.each do |category|
        categories = @plan.categories.where(parent_id: category.id)

        children = if categories.any?
                     plan_tree(categories)
                   else
                     []
                   end

        category_node = category.nodes.first

        data = if category.level.zero?
                 { id: category.id,
                   level: category.level,
                   attributes: { title: category.name_translations,
                                 colour: @plan.configuration_data["level0_options"].find { |option| option["slug"] == category.slug }["colour"],
                                 img: @plan.configuration_data["level0_options"].find { |option| option["slug"] == category.slug }["logo"] },
                   children: children }
               elsif category_node.present?
                 { id: category.id,
                   level: category.level,
                   attributes: { title: category.name_translations,
                                 progress: category_node.progress,
                                 starts_at: category_node.starts_at,
                                 ends_at: category_node.ends_at,
                                 status: category_node.status_translations,
                                 options: category_node.options },
                   children: children }
               else
                 { id: category.id,
                   level: category.level,
                   attributes: { title: category.name_translations },
                   children: children }
               end

        tree.push(data)
      end

      tree
    end
  end
end
