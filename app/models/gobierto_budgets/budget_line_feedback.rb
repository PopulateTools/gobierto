require_dependency "gobierto_budgets"

module GobiertoBudgets
  class BudgetLineFeedback < ApplicationRecord
    belongs_to :site

    scope :by_site, ->(site) { where(site_id: site.id) }
    scope :sorted, -> { order(id: :desc) }

    def self.newest
      sorted.first
    end

    def self.stats(options)
      site = options.fetch :site
      year = options.fetch :year
      budget_line_id = options.fetch :id
      answer1 = options.fetch :answer1
      answer2 = options.fetch :answer2, nil

      base_conditions = {site_id: site.id, year: year, budget_line_id: budget_line_id}


      if answer2.nil?
        total = where(base_conditions).count
        this_answer = where(base_conditions.merge(answer1: answer1)).count
      else
        total = where(base_conditions.merge(answer1: answer1)).count
        this_answer = where(base_conditions.merge(answer1: answer1, answer2: answer2)).count
      end

      if total > 0
        "#{((this_answer.to_f / total.to_f) * 100).to_i} %"
      else
        "0%"
      end
    end
  end
end
