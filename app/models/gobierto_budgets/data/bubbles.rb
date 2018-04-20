# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Bubbles
      def self.dump(site)
        bubble_data_builder = new(site)
        bubble_data_builder.build_data_file
        bubble_data_builder.upload_file
      end

      def self.file_name_for(organization_id)
        ["gobierto_budgets", organization_id, "data", "bubbles.json"].join("/")
      end

      def initialize(site)
        @site = site
        @file_content = []
      end

      attr_reader :site

      def upload_file
        GobiertoCommon::FileUploadService.new(content: @file_content.to_json,
                                              file_name: self.class.file_name_for(site.organization_id),
                                              content_type: "application/json; charset=utf-8").upload!
      end

      def build_data_file
        expense_lines.group_by(&:code).each do |code, lines|
          fill_data_for(code, lines, "expense")
        end

        income_lines.each.group_by(&:code).uniq.each do |code, lines|
          fill_data_for(code, lines, "income")
        end
      end

      def expense_lines
        GobiertoBudgets::BudgetLine.all(where: { site: site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: GobiertoBudgets::FunctionalArea.area_name, level: 2 })
      end

      def income_lines
        GobiertoBudgets::BudgetLine.all(where: { site: site, kind: GobiertoBudgets::BudgetLine::INCOME, area_name: GobiertoBudgets::EconomicArea.area_name, level: 2 })
      end

      def expense_categories
        GobiertoBudgets::FunctionalArea.all_items[GobiertoBudgets::BudgetLine::EXPENSE]
      end

      def income_categories
        GobiertoBudgets::EconomicArea.all_items[GobiertoBudgets::BudgetLine::INCOME]
      end

      def parent_name(collection, code)
        collection.detect { |c, _| c == code[0..-2] }.last
      rescue StandardError
        "Ingresos patrimoniales" if code.starts_with?("5")
      end

      def localized_name_for(code, kind)
        if kind == "income"
          income_categories[code]
        else
          expense_categories[code]
        end
      end

      def fill_data_for(code, budget_lines, kind)
        values = {}
        values_per_inhabitant = {}
        years = budget_lines.map(&:year).sort.reverse
        years.each_with_index do |year, _i|
          if budget_line = budget_lines.detect { |b| b.year == year }
            values.store(year, budget_line.amount)
            values_per_inhabitant.store(year, budget_line.amount_per_inhabitant)
          else
            values.store(year, 0)
            values_per_inhabitant.store(year, 0)
          end
        end
        pct_diff = {}
        years.each_with_index do |year, i|
          if i < years.length - 1
            previous = values[year - 1].to_f
            current = values[year].to_f
            pct_diff.store(year, (((current - previous) / previous) * 100).round(2))
          else
            pct_diff.store(year, 0)
          end
        end

        data = {
          budget_category: kind,
          id: code.to_s,
          "pct_diff": pct_diff,
          "values": values,
          "values_per_inhabitant": values_per_inhabitant
        }

        I18n.locale = :es
        data[:level_2_es] = localized_name_for(code, kind)

        I18n.locale = :ca
        data[:level_2_ca] = localized_name_for(code, kind)

        @file_content.push(data)
      end
    end
  end
end
