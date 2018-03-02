# frozen_string_literal: true

class UpdatePlanTypes < ActiveRecord::Migration[5.1]
  def up
    ::GobiertoPlans::PlanType.all.each do |plan_type|
      plan_type.update_column :name_translations, "en" => plan_type.slug,
                                                  "es" => plan_type.slug,
                                                  "ca" => plan_type.slug
      if plan_type.plans.any?
        plan_type.update_column :site_id, plan_type.plans.first.site_id
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
