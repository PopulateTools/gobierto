# frozen_string_literal: true

module GobiertoBudgets
  class BudgetLinesImporter
    def initialize(site, year)
      @site = site
      @year = year
    end

    def import!
      calculate_totals
      calculate_bubbles
      reset_cache
      publish_event
    end

    private

    attr_reader :site, :year

    def calculate_totals
      GobiertoBudgets::BudgetTotalCalculator.new(site, year).calculate!
    end

    def calculate_bubbles
      GobiertoBudgets::Data::Bubbles.dump(site.place)
    end

    def reset_cache
      Rails.cache.clear
    end

    def publish_event
      action = 'budgets_updated'

      Publishers::GobiertoBudgetsBudgetLineActivity.broadcast_event(action, {
        action: action,
        site_id: site.id
      })
    end
  end
end
