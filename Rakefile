# frozen_string_literal: true

require File.expand_path("../config/application", __FILE__)

Rails.application.load_tasks

# Load tasks from gobierto_data
spec = Gem::Specification.find_by_name "gobierto_budgets_data"
load "#{spec.gem_dir}/lib/tasks/data.rake"
load "#{spec.gem_dir}/lib/tasks/elastic_search_schemas.rake"
load "#{spec.gem_dir}/lib/tasks/budgets_import.rake"
load "#{spec.gem_dir}/lib/tasks/total_budgets_import.rake"

