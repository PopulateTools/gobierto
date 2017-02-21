module GobiertoBudgets
  module Api
    class CategoriesController < ApplicationController
      caches_action :index

      def index
        kind = params[:kind]
        area = GobiertoBudgets::BudgetLine.budget_area_klass_for params[:area]

        if !valid_area_filter(params[:area]) || ( area && !area.valid_kinds.include?(kind) )
          render_404 and return
        end

        if kind.nil? && area.nil?
          categories = {}
          GobiertoBudgets::BudgetLine.budget_areas.each do |area|
            area.valid_kinds.each do |kind|
              categories[area.area_name] ||= {}
              categories[area.area_name][kind] = Hash[area.all_items[kind].sort_by { |k, v| k.to_f } ]
            end
          end
        else
          categories = Hash[area.all_items[kind].sort_by { |k, v| k.to_f } ]
        end

        respond_to do |format|
          format.json do
            render json: categories.to_json
          end
        end
      end

      private

        def valid_area_filter(area_name)
          are_name.nil? || area_klass_for(area_name)
        end
    end
  end
end
