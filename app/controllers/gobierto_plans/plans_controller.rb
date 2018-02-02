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
      @node_number = GobiertoPlans::CategoriesNode.where(category_id: @plan.categories.pluck(:id)).pluck(:node_id).uniq.size

      @levels = @plan.categories.maximum("level")
      plan_tree = plan_tree(@plan.categories.where(parent_id: nil))

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

    def uid(category)
      uid = ""
      categories = category.plan.categories

      for i in 0..category.level
        index = categories.where(level: category.level).index(category)
        uid = index.to_s + uid
        if category.parent_id != nil
          category = categories.where(id: category.parent_id).first
          uid = "." + uid
        end
      end

      uid
    end

    def children_progress(category)
      descendants_array = category.descendants
      descendants = GobiertoPlans::Category.where(id: descendants_array.map(&:id))
      max_level = descendants.maximum(:level)

      descendants_leaves = descendants.where(level: max_level)
      if descendants_leaves.any?
        descendants_leaves_id = descendants_leaves.pluck(:id)
        node_ids = GobiertoPlans::CategoriesNode.where(category_id: descendants_leaves_id).pluck(:node_id)
        nodes = GobiertoPlans::Node.where(id: node_ids)
        progress_sum = nodes.sum(:progress)/node_ids.length
      else
        0
      end
    end

    def children_levels(category)
      childrens = {}

      descendants_array = category.descendants

      unless descendants_array.empty?
        descendants = GobiertoPlans::Category.where(id: descendants_array.map(&:id))
        max_level = descendants.maximum(:level)
        min_level = descendants.minimum(:level)

        for i in min_level..max_level
          level_children = descendants.where(level: i)
          childrens["level_#{i.to_s}"] = level_children.size

          if i == max_level
            child_leave = level_children.first
            node_ids = GobiertoPlans::CategoriesNode.where(category_id: child_leave.id).pluck(:node_id)
            nodes = GobiertoPlans::Node.where(id: node_ids)
            childrens["level_#{(i + 1).to_s}"] = nodes.size
          end
        end
      else
        node_ids = GobiertoPlans::CategoriesNode.where(category_id: category.id).pluck(:node_id)
        nodes = GobiertoPlans::Node.where(id: node_ids)
        if nodes.any?
          childrens["level_#{(category.level + 1).to_s}"] = nodes.size
        end
      end

      childrens
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
                   uid: uid(category),
                   parent_id: category.parent_id,
                   children_progress: children_progress(category),
                   children_levels: children_levels(category),
                   level: category.level,
                   attributes: { title: category.name_translations,
                                 img: @plan.configuration_data["level0_options"].find { |option| option["slug"] == category.slug }["logo"] },
                   children: children }
               elsif category_node.present?
                 { id: category.id,
                   uid: uid(category),
                   parent_id: category.parent_id,
                   children_progress: children_progress(category),
                   children_levels: children_levels(category),
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
                   uid: uid(category),
                   parent_id: category.parent_id,
                   children_progress: children_progress(category),
                   children_levels: children_levels(category),
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
