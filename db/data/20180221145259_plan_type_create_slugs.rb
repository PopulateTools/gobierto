# frozen_string_literal: true

class PlanTypeCreateSlugs < ActiveRecord::Migration[5.1]
  def up
    ::GobiertoPlans::PlanType.all.each do |plan_type|
      plan_type.update_column :slug, plan_type.attributes_for_slug.join("-").tr("_", " ").parameterize
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
