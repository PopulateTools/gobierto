module GobiertoBudgets
  class BudgetLineFeedback < ApplicationRecord
    belongs_to :site

    def self.stats(item, force_answer2 = nil)
      site = item.site
      year = item.year
      budget_line_id = item.budget_line_id
      answer1 = item.answer1
      answer2 = item.answer2

      base_conditions = {site_id: site.id, year: year, budget_line_id: budget_line_id}

      total = where(base_conditions).count

      this_answer = if answer2.nil?
                      where(base_conditions.merge(answer1: answer1)).count
                    else
                      if force_answer2.present?
                        where(base_conditions.merge(answer1: answer1, answer2: force_answer2)).count
                      else
                        where(base_conditions.merge(answer1: answer1, answer2: answer2)).count
                      end
                    end

      if total > 0
        "#{((this_answer.to_f / total.to_f) * 100).to_i} %"
      else
        "0%"
      end
    end
  end
end
