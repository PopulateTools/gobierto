module GobiertoBudgets
  module Api
    class CategoriesController < ApplicationController
      caches_action :index
      skip_before_action :authenticate_user_in_site, only: [:index]

      def index
        kind      = params[:kind]
        area_name = params[:area]
        year      = params[:with_data]
        with_data = year.present?
        render_404 and return if (area_name == GobiertoBudgets::FunctionalArea.area_name and kind == BudgetLine::INCOME)

        if kind.nil? && area_name.nil?
          categories = {}
          GobiertoBudgets::BudgetArea.all_areas.each do |area|
            if area == GobiertoBudgets::CustomArea
              next if !GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::INCOME, area: area) &&
                !GobiertoBudgets::BudgetLine.any_data?(site: current_site, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: area)
            end

            area.available_kinds.each do |kind|
              categories[area.area_name] ||= {}
              categories[area.area_name][kind] = with_data ? area_items_with_data(area, kind, year) : area_items(area, kind)
            end
          end
        else
          area = GobiertoBudgets::BudgetArea.klass_for(area_name)
          categories = with_data ? area_items_with_data(area, kind, year) : area_items(area, kind)
        end

        respond_to do |format|
          format.json do
            render json: categories.to_json
          end
        end
      end

      private

      def area_items(area, kind)
        if area == GobiertoBudgets::CustomArea
          Hash[current_site.custom_budget_lines_categories.map{|c| [c.code, c.name]}]
        else
          Hash[area.all_items[kind].sort_by{ |k,v| k.to_f }]
        end
      end

      def area_items_with_data(area, kind, year)
        all_items = area_items(area, kind)
        all_data = GobiertoBudgets::BudgetLine.all(where: {area_name: area.area_name, kind: kind, year: year, site: current_site})
        all_items.slice(*all_data.map(&:code))
      end
    end
  end
end
