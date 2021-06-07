# frozen_string_literal: true

namespace :test do
  modules = %w{
    gobierto_admin
    gobierto_attachments
    gobierto_budgets
    gobierto_calendars
    gobierto_cms gobierto_common
    gobierto_core
    gobierto_dashboards
    gobierto_data
    gobierto_exports
    gobierto_indicators
    gobierto_investments
    gobierto_observatory
    gobierto_people
    gobierto_plans
    gobierto_visualizations
    gobierto_others
    gobierto_engines
  }

  modules.each do |mod|
    desc "run test for module #{mod}.safe_constantize "
    task "#{mod}".to_sym, [:fail_fast_enable] => :environment do |_t, args|
      files = `find test -path '*#{mod}*' -name '*_test.rb' | grep -v '#{mod}\/gobierto_'`.gsub("\n"," ")
      cmd = "bin/rails test #{files} #{"--fail-fast" if args[:fail_fast_enable]}"
      puts cmd
      puts `#{cmd}`
    end
  end
end
