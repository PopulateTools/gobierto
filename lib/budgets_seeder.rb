# frozen_string_literal: true

require_relative "../test/factories/budget_line_factory"

class BudgetsSeeder

  def self.seed!
    puts "* Seeding GobiertoBudgets::BudgetLine"

    (2014..Date.current.year).each do |year|
      GobiertoBudgets::BudgetArea.all_areas_names.each do |area_name|
        default_args = {
          area: area_name,
          year: year,
          kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE
        }

        %w(1 2 3).each do |code|
          BudgetLineFactory.new(default_args.merge(
            code: code,
            indexes: [:forecast]
          ))
          BudgetLineFactory.new(default_args.merge(
            code: code,
            indexes: [:executed],
            amount: BudgetLineFactory.default_amount / 2
          ))
        end
      end
    end
  end

end
