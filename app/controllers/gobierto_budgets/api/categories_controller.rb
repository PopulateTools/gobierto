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
          BudgetArea.all_areas.each do |klass|
            area_name = klass.area_name
            BudgetLine.all_kinds.each do |kind|
              next if kind == GobiertoBudgets::BudgetLine::INCOME and klass == GobiertoBudgets::FunctionalArea

              categories[area_name] ||= {}
              categories[area_name][kind] = Hash[klass.all_items[kind].sort_by{ |k,v| k.to_f }]
            end
          end
        else
          klass = BudgetArea.klass_for(area)
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
