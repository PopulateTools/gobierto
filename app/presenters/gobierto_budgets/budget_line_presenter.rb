module GobiertoBudgets
  class BudgetLinePresenter

    def self.load(id, site)
      return nil if id.nil?
      organization_id, year, code, kind, area_name = id.split("/")
      area = case area_name
             when EconomicArea.area_name
               EconomicArea
             when FunctionalArea.area_name
               FunctionalArea
             when CustomArea.area_name
               CustomArea
             end
      self.new(organization_id: organization_id, year: year, code: code, kind: kind, area: area, site: site)
    end

    def initialize(attributes)
      @attributes = attributes.symbolize_keys
    end

    def id
      [
        @attributes[:organization_id],
        @attributes[:year],
        area_code,
        @attributes[:kind]
      ].join("/")
    end

    def area_code
      if @attributes[:custom_code].present?
        [@attributes[:custom_code], @attributes[:code], "c"].join("/")
      elsif @attributes[:functional_code].present?
        [@attributes[:functional_code], @attributes[:code], "f"].join("/")
      else
        code
      end
    end

    def category
      @category ||= if @attributes[:site]
                      Category.find_by(site: @attributes[:site], area_name: area_name, kind: kind, code: code)
                    end
    end

    def name(locale = nil)
      current_locale = I18n.locale
      I18n.locale = locale if locale
      name = category ? category.name : GobiertoBudgets::Category.default_name(area, kind, code)
      I18n.locale = current_locale
      name
    end

    def description(locale = nil)
      current_locale = I18n.locale
      I18n.locale = locale if locale
      description = category ? category.description : GobiertoBudgets::Category.default_description(area, kind, code)
      I18n.locale = current_locale
      description
    end

    def amount
      @attributes[:amount]
    end

    def amount_per_inhabitant
      @attributes[:amount_per_inhabitant]
    end

    def percentage_of_total
      total_amount = total || GobiertoBudgets::BudgetTotal.for(@attributes[:organization_id], @attributes[:year])
      return 0 if total_amount == 0
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

    def custom_code
      @attributes[:custom_code]
    end

    def functional_code
      @attributes[:functional_code]
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
      if @attributes[:custom_code].present?
        "economic-custom"
      elsif @attributes[:functional_code].present?
        "economic-functional"
      else
        area.area_name
      end
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
