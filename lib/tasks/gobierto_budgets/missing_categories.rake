# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :missing_categories do
    desc "Check missing categories"
    task :check, [:site_domain] => [:environment] do |_t, args|
      site = Site.find_by!(domain: args[:site_domain])
      ine_code = site.place.id

      missing = []
      [GobiertoBudgets::BudgetLine::INCOME, GobiertoBudgets::BudgetLine::EXPENSE].each do |kind|
        GobiertoBudgets::BudgetArea.all_areas_names.each do |area_name|
          missing_names = GobiertoBudgets::BudgetLine.all(where: { site: site, place: site.place, kind: kind, area_name: area_name }).select{ |bl| bl.name.blank? }
          if missing_names.any?
            missing = missing.concat(missing_names)
          end
        end
      end

      if missing.length == 0
        puts " - No missing category names for #{site.name} - #{site.domain}"
        exit(0)
      end

      file_name = "/tmp/missing_categories_#{site.id}.csv"
      CSV.open(file_name, "wb") do |csv|
        csv << %W{ Area Tipo Codigo Nombre Descripcion }
        while missing.any?
          budget_line = missing.pop
          csv << [ budget_line.area.area_name[0].upcase, budget_line.kind, budget_line.code, budget_line.name, budget_line.description ]
          missing.delete_if do |other_budget_line|
            if other_budget_line.id.split('/')[2..-1] == budget_line.id.split('/')[2..-1]
              missing.delete(other_budget_line)
            end
          end
        end
      end

      puts
      puts " - Written file #{file_name}"
      puts
    end
  end
end
