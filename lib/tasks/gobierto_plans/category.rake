# frozen_string_literal: true

namespace :gobierto_plans do
  namespace :category do
    desc "Cache category progress"
    task :progress_cache, [:plan_slug] => [:environment] do |_t, args|
      plan = ::GobiertoPlans::Plan.find_by!(slug: args[:plan_slug])
      puts "== Caching category progress for plan #{plan.title}=="

      plan.categories.each do |category|
        category.progress = category.children_progress
        category.save
      end
    end

    desc "Cache category uid"
    task :uid_cache, [:plan_slug] => [:environment] do |_t, args|
      plan = ::GobiertoPlans::Plan.find_by!(slug: args[:plan_slug])
      puts "== Caching category uid for plan #{plan.title}=="

      plan.categories.each do |category|
        category.uid = category.calculate_uid
        category.save
      end
    end
  end
end
