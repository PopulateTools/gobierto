# frozen_string_literal: true

class GobiertoPlans::PlanTree
  attr_reader :plan

  def initialize(plan)
    @plan = plan
    @categories = CollectionDecorator.new(@plan.categories.where(term_id: nil).sorted, decorator: GobiertoPlans::CategoryTermDecorator)
    @vocabulary = @plan.categories_vocabulary
    @tree_decorator = TreeDecorator.new(
      terms_tree(@vocabulary.terms),
      decorator: ::GobiertoPlans::CategoryTermDecorator,
      options: { plan: @plan, vocabulary: @vocabulary, site: @plan.site }
    )
  end

  def call
    plan_tree(@tree_decorator, true)
  end

  private

  def terms_tree(relation)
    relation.order(position: :asc).where(level: relation.minimum(:level)).inject({}) do |tree, term|
      tree.merge(term.ordered_tree)
    end
  end

  def max_level
    @max_level ||= @vocabulary.maximum_level
  end

  def counter?
    @counter ||= !@plan.configuration_data&.dig("hide_level0_counters")
  end

  def plan_tree(decorated_tree, include_nodes = false)
    return [] unless decorated_tree

    decorated_tree.map do |category, subtree|
      children = if include_nodes && subtree.blank? && category.nodes.exists?
                   category.nodes_data
                 else
                   plan_tree(subtree, include_nodes)
                 end
      attributes = { title: category.name_translations,
                     parent_id: category.parent_id,
                     progress: category.progress }
      if category.level.zero?
        attributes[:img] = @plan.configuration_data&.dig("level0_options")&.find { |option| option["slug"] == category.slug }&.dig("logo") || ""
        attributes[:counter] = counter?
      end

      attributes[:children_count] = subtree.blank? ? category.nodes.count : subtree.count
      attributes[:nodes_list_path] = url_helper.gobierto_plans_api_plan_projects_path(plan_id: @plan.id, category_id: category.id)

      { id: category.id,
        uid: category.uid,
        type: "category",
        max_level: category.level == max_level,
        level: category.level,
        attributes: attributes,
        children: children }
    end
  end

  def url_helper
    Rails.application.routes.url_helpers
  end
end
