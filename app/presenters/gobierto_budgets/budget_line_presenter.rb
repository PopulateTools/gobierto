module GobiertoBudgets
  class BudgetLinePresenter

    def initialize(attributes)
      @attributes = attributes.symbolize_keys
    end

    def category
      @category ||= if @attributes[:site]
                      Category.find_by(site: @attributes[:site], area_name: area_name, kind: kind, code: code)
                    end
    end

    def name
      category ? category.name : GobiertoBudgets::Category.default_name(area, kind, code)
    end

    def description
      category ? category.description : GobiertoBudgets::Category.default_description(area, kind, code)
    end

    def amount
      @attributes[:amount]
    end

    def amount_per_inhabitant
      @attributes[:amount_per_inhabitant]
    end

    def percentage_of_total
      total_amount = total || GobiertoBudgets::BudgetTotal.for(@attributes[:ine_code], @attributes[:year])
      ((amount.to_f / total_amount.to_f)*100).round(2)
    end

    def percentage_compared_with(other_value)
      amount.to_f / other_value.to_f
    end

    def attr
      @attributes
    end

    def total
      @attributes[:total]
    end

    def total_per_inhabitant
      @attributes[:total_budget_per_inhabitant]
    end

    def code
      @attributes[:code]
    end

    def level
      @attributes[:level]
    end

    def kind
      @attributes[:kind]
    end

    def area
      @attributes[:area]
    end

    def area_name
      area.area_name
    end

    def year
      @attributes[:year]
    end

    def parent_code
      @attributes[:parent_code].to_s
    end

    def to_param
      {
        id: code,
        year: year,
        kind: kind,
        area_name: area_name
      }
    end

    def as_json(attrs = {})
      {
        name: self.name,
        amount: self.amount,
        amount_per_inhabitant: self.amount_per_inhabitant,
        percentage_of_total: self.percentage_of_total,
        total: self.total,
        total_per_inhabitant: self.total_per_inhabitant,
        code: self.code,
        level: self.level
      }
    end
  end
end
