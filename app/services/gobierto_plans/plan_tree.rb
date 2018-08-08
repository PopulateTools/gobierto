# frozen_string_literal: true

class GobiertoPlans::PlanTree
  attr_reader :plan

  def initialize(plan)
    @plan = plan
    @categories = @plan.categories.where(term_id: nil).sorted
  end

  def call
    plan_tree(@categories)
  end

  private

  def max_level
    @plan.categories.maximum(:level)
  end

  def plan_tree(categories, tree = [])
    categories.each do |category|
      categories = @plan.categories.sort_by_uid.where(parent_id: category.id)

      children = if categories.exists?
                   plan_tree(categories)
                 else
                   []
                 end

      category_nodes = category.nodes

      data = if category.level.zero?
               logo_url = if logo_options = @plan.configuration_data["level0_options"].find { |option| option["slug"] == category.slug }
                            logo_options["logo"]
                          else
                            ""
                          end
               counter = !@plan.configuration_data["hide_level0_counters"]
               { id: category.id,
                 uid: category.uid,
                 type: "category",
                 max_level: category.level == max_level,
                 level: category.level,
                 attributes: { title: category.name_translations,
                               parent_id: category.parent_id,
                               progress: category.progress,
                               img: logo_url,
                               counter: counter },
                 children: children }
             elsif category_nodes.exists?
               nodes = []

               category_nodes.each_with_index do |node, index|
                 nodes.push(id: node.id,
                            uid: category.uid + "." + index.to_s,
                            type: "node",
                            level: category.level + 1,
                            attributes: { title: node.name_translations,
                                          parent_id: category.id,
                                          progress: node.progress,
                                          starts_at: node.starts_at,
                                          ends_at: node.ends_at,
                                          status: node.status_translations,
                                          options: node.options },
                            children: [])
               end

               { id: category.id,
                 uid: category.uid,
                 type: "category",
                 max_level: category.level == max_level,
                 level: category.level,
                 attributes: { title: category.name_translations,
                               parent_id: category.parent_id,
                               progress: category.progress },
                 children: nodes }
             else
               { id: category.id,
                 uid: category.uid,
                 type: "category",
                 max_level: category.level == max_level,
                 level: category.level,
                 attributes: { title: category.name_translations,
                               parent_id: category.parent_id,
                               progress: category.progress },
                 children: children }
             end

      tree.push(data)
    end

    tree
  end
end
