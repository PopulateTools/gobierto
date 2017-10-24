module GobiertoBudgets
  module Data
    class Bubbles
      def self.dump(place)
        bubble_data_builder = new(place)
        bubble_data_builder.build_data_file
        bubble_data_builder.upload_file
      end

      def self.file_name_for(place)
        ['gobierto_budgets', place.id, 'data', 'bubbles.json'].join('/')
      end

      def initialize(place)
        @place = place
        @file_content = []
      end

      attr_reader :place

      def upload_file
        tmp_file = Tempfile.new
        tmp_file.binmode
        tmp_file.write(@file_content.to_json)
        tmp_file.close
        file = ActionDispatch::Http::UploadedFile.new(filename: "bubbles.json", tempfile: tmp_file)
        ::FileUploader::S3.new(file: file, file_name: self.class.file_name_for(place)).call
      end

      def build_data_file
        base_conditions = {place: place, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: GobiertoBudgets::FunctionalArea.area_name, level: 2}
        expense_categories.each do |code, name|
          fill_data_for(code, name, base_conditions, 'expense')
        end

        base_conditions = {place: place, kind: GobiertoBudgets::BudgetLine::INCOME, area_name: GobiertoBudgets::EconomicArea.area_name, level: 2}
        income_categories.each do |code, name|
          fill_data_for(code, name, base_conditions, 'income')
        end
      end

      def all_expense_categories
        GobiertoBudgets::FunctionalArea.all_items[GobiertoBudgets::BudgetLine::EXPENSE]
      end

      def all_income_categories
        GobiertoBudgets::EconomicArea.all_items[GobiertoBudgets::BudgetLine::INCOME]
      end

      def expense_categories
        all_expense_categories.select{ |code, _| code.length == 2 }
      end

      def income_categories
        all_income_categories.select{ |code, _| code.length == 2 }
      end

      def parent_name(collection, code)
        collection.detect{ |c, _| c == code[0..-2] }.last
      rescue
        if code.starts_with?("5")
          "Ingresos patrimoniales"
        end
      end

      def localized_name_for(code, kind)
        if kind == 'income'
          income_categories[code]
        else
          expense_categories[code]
        end
      end

      def fill_data_for(code, name, base_conditions, kind)
        budget_lines = GobiertoBudgets::BudgetLine.all(where: base_conditions.merge(code: code))

        values = {}
        values_per_inhabitant = {}
        years = budget_lines.map(&:year).sort.reverse
        years.each_with_index do |year, i|
          if budget_line = budget_lines.detect{ |b| b.year == year}
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
            pct_diff.store(year, (((current - previous)/previous)*100).round(2))
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
        data.merge!({
          level_2_es: localized_name_for(code, kind)
        })

        I18n.locale = :ca
        data.merge!({
          level_2_ca: localized_name_for(code, kind)
        })

        @file_content.push(data)
      end
    end
  end
end
