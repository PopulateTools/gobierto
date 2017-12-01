module GobiertoBudgets
  class BudgetLineExportPresenter < BudgetLinePresenter

    INDEX_KEYS = { GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast => :value_budget_initial,
                   GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated => :value_budget_modified,
                   GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed => :value_budget_execution }

    def initialize(attributes)
      super
      @attributes[:index_values] = Hash[INDEX_KEYS.values.product([nil])].tap do |attrs|
        attrs[INDEX_KEYS[@attributes[:index]]] = @attributes[:total] if @attributes[:index].present?
      end
    end

    def self.csv_columns
      ['ID',
       'code',
       'year',
       'area',
       'income/expense',
       'name',
       'description',
       'value_budget_initial',
       'value_budget_modified',
       'value_execution',
       'level',
       'parent_code',
       'updated_at',
       'municipality_id']
    end

    def index_values
      @attributes[:index_values]
    end

    def merge!(budget_line)
      if id == budget_line.id
        index_values.merge!(budget_line.index_values) { |index, old, new| new.present? ? new : old }
      end
    end

    def updated_at
      @attributes[:updated_at]
    end

    def index
      @attributes[:index]
    end

    def municipality_id
      @attributes[:site].municipality_id
    end

    def as_json(attrs = {})
      { id: id,
        code: code,
        year: year,
        area: area_name,
        income_expense: kind,
        name: name,
        description: description,
        level: level,
        parent_code: parent_code,
        updated_at: updated_at,
        municipality_id: municipality_id }.merge(index_values)
    end

    def as_csv
      [id,
       code,
       year,
       area_name,
       kind,
       name,
       description,
       index_values[:value_budget_initial],
       index_values[:value_budget_modified],
       index_values[:value_budget_execution],
       level,
       parent_code,
       updated_at,
       municipality_id]
    end
  end
end
