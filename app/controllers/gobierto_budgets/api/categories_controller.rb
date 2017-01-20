module GobiertoBudgets
  module Api
    class CategoriesController < ApplicationController
      caches_action :index

      def index
        kind = params[:kind]
        area = params[:area]
        render_404 and return if area == 'functional' and kind == 'I'

        if kind.nil? && area.nil?
          categories = {}
          [GobiertoBudgets::EconomicArea, GobiertoBudgets::FunctionalArea].each do |klass|
            area_name = (klass == GobiertoBudgets::EconomicArea) ? GobiertoBudgets::BudgetLine::ECONOMIC : GobiertoBudgets::BudgetLine::FUNCTIONAL
            [GobiertoBudgets::BudgetLine::INCOME, GobiertoBudgets::BudgetLine::EXPENSE].each do |kind|
              next if kind == GobiertoBudgets::BudgetLine::INCOME and klass == GobiertoBudgets::FunctionalArea

              categories[area_name] ||= {}
              categories[area_name][kind] = Hash[klass.all_items[kind].sort_by{ |k,v| k.to_f }]
            end
          end
        else
          klass = area == 'economic' ? GobiertoBudgets::EconomicArea : GobiertoBudgets::FunctionalArea
          categories = Hash[klass.all_items[kind].sort_by{ |k,v| k.to_f }]
        end


        respond_to do |format|
          format.json do
            render json: categories.to_json
          end
        end
      end
    end
  end
end
