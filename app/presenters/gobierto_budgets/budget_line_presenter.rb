# frozen_string_literal: true

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
      new(organization_id: organization_id, year: year, code: code, kind: kind, area: area, site: site)
    end

    def initialize(attributes)
      @attributes = attributes.symbolize_keys
    end

    def id
      (@attributes.values_at(:organization_id, :year, :code, :kind) + [@attributes[:area].area_name]).join("/")
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
      ((amount.to_f / total_amount.to_f) * 100).round(2)
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
        name: name,
        amount: amount,
        amount_per_inhabitant: amount_per_inhabitant,
        percentage_of_total: percentage_of_total,
        total: total,
        total_per_inhabitant: total_per_inhabitant,
        code: code,
        level: level
      }
    end
  end
end
