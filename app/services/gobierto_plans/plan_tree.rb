# frozen_string_literal: true

class GobiertoPlans::PlanTree
  attr_reader :plan

  def initialize(plan)
    @plan = plan
    @vocabulary = @plan.categories_vocabulary
    @tree_decorator = TreeDecorator.new(
      terms_tree(@vocabulary.terms),
      decorator: ::GobiertoPlans::CategoryTermDecorator,
      options: {
        plan: @plan,
        vocabulary: @vocabulary,
        site: @plan.site,
        with_published_versions: true,
        cached_attributes: { progress: progresses_with_version }
      }
    )
    @nodes_count = plan.nodes.joins(:categories).group(:category_id).reorder("").count(:id)
  end

  def call(include_nodes = false)
    plan_tree(@tree_decorator, include_nodes)
  end

  def global_progress
    return unless (progress_values = progresses_with_version.values.compact).present?

    progress_values.sum / progress_values.count.to_f
  end

  private

  def progresses_with_version
    @progresses_with_version ||= CollectionDecorator.new(
      @plan.nodes.published,
      decorator: GobiertoPlans::ProjectDecorator,
      opts: { plan: @plan, site: @plan.site }
    ).inject({}) do |progresses, node|
      progresses.update(
        node.id => node.at_current_version.progress
      )
    end
  end

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

  def plan_tree(decorated_tree, include_nodes)
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

      attributes[:children_count] = subtree.blank? ? @nodes_count.fetch(category.id, 0) : subtree.count
      attributes[:nodes_list_path] = url_helper.gobierto_plans_api_plan_projects_path(plan_id: @plan.id, category_id: category.id, locale: I18n.locale)

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
