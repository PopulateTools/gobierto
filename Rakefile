# frozen_string_literal: true

require File.expand_path("../config/application", __FILE__)

Rails.application.load_tasks

# Load tasks from gobierto_data
spec = Gem::Specification.find_by_name "gobierto_budgets_data"
load "#{spec.gem_dir}/lib/tasks/data.rake"
