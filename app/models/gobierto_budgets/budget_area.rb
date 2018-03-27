# frozen_string_literal: true

module GobiertoBudgets
  class BudgetArea
    include Describable
    include Searchable

    def self.all_areas
      [EconomicArea, FunctionalArea, CustomArea]
    end

    def self.all_areas_names
      all_areas.map(&:area_name)
    end

    def self.klass_for(area_name)
      all_areas.select { |area_klass| area_klass.area_name == area_name }.first
    end
  end
end
