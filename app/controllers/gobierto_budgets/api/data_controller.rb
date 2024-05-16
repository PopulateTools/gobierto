module GobiertoBudgets
  module Api
    class DataController < ApplicationController
      include GobiertoBudgets::ApplicationHelper

      caches_action(
        :lines,
        :budget_per_inhabitant,
        :budget,
        cache_path: proc { |c| cache_service.prefixed("#{c.request.url}?locale=#{I18n.locale}") }
      )

      skip_before_action :authenticate_user_in_site, only: [:budget_line, :available_years]

      def budget
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @code = params[:code]

        @category_name = @kind == 'G' ? I18n.t("controllers.gobierto_budgets.api.data.expense") : I18n.t("controllers.gobierto_budgets.api.data.income")
        budget_data = budget_data(@year, 'amount')
        budget_data_previous_year = budget_data(@year - 1, 'amount')

        result = if budget_data.present? && budget_data_previous_year.present?
          position = budget_data[:position].to_i
          sign = sign(budget_data[:value], budget_data_previous_year[:value])

          {
            title: @category_name,
            sign: sign,
            value: format_currency(budget_data[:value]),
            delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
            ranking_position: position,
            ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 2),
            ranking_url: ''
          }
        else
          {}
        end

        respond_to do |format|
          format.json do
            render json: result
          end
        end
      end

      def budget_line
        result = GobiertoBudgets::BudgetLine.find_details(
          type: params[:area],
          id: params[:id]
        )

        render json: result
      rescue BudgetLine::RecordNotFound
        render json: { error: "not-found" }, status: 404
      end

      def available_years
        years = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.with_data(
          index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        ).sort

        render json: years
      end

      def budget_per_inhabitant
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @code = params[:code]

        @category_name = @kind == 'G' ? I18n.t("controllers.gobierto_budgets.api.data.expense") : I18n.t("controllers.gobierto_budgets.api.data.income")
        budget_data = budget_data(@year, 'amount_per_inhabitant')
        budget_data_previous_year = budget_data(@year - 1, 'amount_per_inhabitant')
        result = if budget_data.present? && budget_data_previous_year.present?
          position = budget_data[:position].to_i
          sign = sign(budget_data[:value], budget_data_previous_year[:value])

          {
            sign: sign,
            title: "#{@category_name} por habitante",
            value: format_currency(budget_data[:value]),
            delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
            ranking_position: position,
            ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 2),
            ranking_url: ''
          }
        else
          {}
        end

        respond_to do |format|
          format.json do
            render json: result
          end
        end
      end

      def lines
        data_line = GobiertoBudgets::Data::Lines.new place: current_site.place, organization_id: current_site.organization_id,
          organization_name: current_site.organization_name, year: params[:year], what: params[:what], kind: params[:kind],
          code: params[:code], area: params[:area], include_next_year: params[:include_next_year],
          comparison: params[:comparison]

        respond_lines_to_json data_line
      end

      def budget_execution_comparison
        year = params[:year].to_i
        kind = params[:kind]
        organization_id = params[:organization_id]
        area = params[:area]

        lines = GobiertoBudgets::Data::BudgetExecutionComparison.extract_lines(site: current_site, year: year, kind: kind, organization_id: organization_id, area: area)
        site_stats = GobiertoBudgets::SiteStats.new site: current_site, year: year
        last_update = site_stats.budgets_data_updated_at

        respond_to do |format|
          format.json do
            render json: {
              last_update: last_update ? last_update.strftime('%F') : nil,
              lines: lines
            }
          end
        end
      end

      private

      def budget_data(year, field)
        result = GobiertoBudgets::BudgetLine.find(
          year: year,
          code: @code,
          kind: @kind,
          type: @area,
          variable: field,
          organization_id: params[:organization_id],
          updated_forecast: false
        )

        result ? { value: result[field] } : nil
      end

      def delta_percentage(value, old_value)
        return "" if value.nil? || old_value.nil?
        ((value.to_f - old_value.to_f)/old_value.to_f) * 100
      end

      def respond_lines_to_json(data_line)
        respond_to do |format|
          format.json do
            render json: data_line.to_h
          end
        end
      end

    end
  end
end
