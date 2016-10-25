module GobiertoBudgets
  module Api
    class DataController < ApplicationController
      include GobiertoBudgets::ApplicationHelper

      # TODO: this is a comment to remember this cache
      #       It's not compatible yet with Rails 5. See https://github.com/rails/actionpack-action_caching/pull/33
      # caches_action :total_budget, :total_budget_execution, :population, :total_budget_per_inhabitant, :lines,
      #               :budget, :budget_execution, :budget_per_inhabitant, :budget_percentage_over_total, :debt

      def total_budget
        year = params[:year].to_i
        total_budget_data = total_budget_data(year, 'total_budget')
        total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget', false)
        position = total_budget_data[:position].to_i
        sign = sign(total_budget_data[:value], total_budget_data_previous_year[:value])

        respond_to do |format|
          format.json do
            render json: {
              title: 'Gasto total',
              sign: sign,
              value: format_currency(total_budget_data[:value]),
              delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data[:value], total_budget_data_previous_year[:value]), precision: 2),
              ranking_position: position,
              ranking_total_elements: helpers.number_with_precision(total_budget_data[:total_elements], precision: 0),
              ranking_url: gobierto_budgets_places_ranking_path(year,'G','economic','amount', page: GobiertoBudgets::Ranking.page_from_position(position), ine_code: params[:ine_code])
            }.to_json
          end
        end
      end

      def population
        year = params[:year].to_i
        no_data_this_year = nil
        population_data = GobiertoBudgets::Population.ranking_hash_for(params[:ine_code].to_i,year)
        if population_data[:value].nil?
          year -= 1
          population_data = GobiertoBudgets::Population.ranking_hash_for(params[:ine_code].to_i,year)
          no_data_this_year = year
        end
        population_data_previous_year = GobiertoBudgets::Population.ranking_hash_for(params[:ine_code].to_i,year - 1)
        position = population_data[:position]
        sign = sign(population_data[:value], population_data_previous_year[:value])

        respond_to do |format|
          format.json do
            render json: {
              title: 'Habitantes',
              sign: sign,
              value: helpers.number_with_delimiter(population_data[:value], precision: 0, strip_insignificant_zeros: true),
              delta_percentage: helpers.number_with_precision(delta_percentage(population_data[:value], population_data_previous_year[:value]), precision: 2),
              ranking_position: position,
              ranking_total_elements: helpers.number_with_precision(population_data[:total_elements], precision: 0),
              ranking_url: gobierto_budgets_population_ranking_path(year, page: GobiertoBudgets::Ranking.page_from_position(position), ine_code: params[:ine_code]),
              no_data_this_year: no_data_this_year
            }.to_json
          end
        end
      end

      def total_budget_per_inhabitant
        year = params[:year].to_i
        total_budget_data = total_budget_data(year, 'total_budget_per_inhabitant')
        total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget_per_inhabitant', false)
        position = total_budget_data[:position].to_i
        sign = sign(total_budget_data[:value], total_budget_data_previous_year[:value])

        respond_to do |format|
          format.json do
            render json: {
              title: 'Gasto por habitante',
              sign: sign,
              value: helpers.number_to_currency(total_budget_data[:value], precision: 0, strip_insignificant_zeros: true),
              delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data[:value], total_budget_data_previous_year[:value]), precision: 2),
              ranking_position: position,
              ranking_total_elements: helpers.number_with_precision(total_budget_data[:total_elements], precision: 0),
              ranking_url: gobierto_budgets_places_ranking_path(year,'G','economic','amount_per_inhabitant', page: GobiertoBudgets::Ranking.page_from_position(position), ine_code: params[:ine_code])
            }.to_json
          end
        end
      end

      def lines
        @place = INE::Places::Place.find(params[:ine_code])
        data_line = GobiertoBudgets::Data::Lines.new place: @place, year: params[:year], what: params[:what], kind: params[:kind], code: params[:code], area: params[:area]

        respond_lines_to_json data_line
      end

      def compare
        @places = get_places params[:ine_codes]
        data_line = GobiertoBudgets::Data::Lines.new place: @places, year: params[:year], what: params[:what], kind: params[:kind], code: params[:code], area: params[:area]

        respond_lines_to_json data_line
      end

      def budget
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @code = params[:code]

        @category_name = @kind == 'G' ? 'Gasto' : 'Ingreso'

        budget_data = budget_data(@year, 'amount')
        budget_data_previous_year = budget_data(@year - 1, 'amount', false)
        position = budget_data[:position].to_i
        sign = sign(budget_data[:value], budget_data_previous_year[:value])

        respond_to do |format|
          format.json do
            render json: {
              title: @category_name,
              sign: sign,
              value: format_currency(budget_data[:value]),
              delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
              ranking_position: position,
              ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 0),
              ranking_url: gobierto_budgets_places_ranking_path(@year,@kind,@area,'amount',@code.parameterize,page: GobiertoBudgets::Ranking.page_from_position(position), ine_code: params[:ine_code])
            }.to_json
          end
        end
      end

      def budget_execution
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @code = params[:code]

        @category_name = @kind == 'G' ? 'Gasto ejecutado vs presupuestado' : 'Ingreso ejecutado vs presupuestado'

        budget_executed = budget_data_executed(@year, 'amount')
        budget_planned = budget_data(@year, 'amount')
        sign = sign(budget_executed[:value], budget_planned[:value])

        respond_to do |format|
          format.json do
            render json: {
              title: @category_name,
              sign: sign,
              value: format_currency(budget_executed[:value]),
              delta_percentage: helpers.number_with_precision(delta_percentage(budget_executed[:value], budget_planned[:value]), precision: 2),
            }.to_json
          end
        end
      end

      def budget_per_inhabitant
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @code = params[:code]

        @category_name = @kind == 'G' ? 'Gasto' : 'Ingreso'
        budget_data = budget_data(@year, 'amount_per_inhabitant')
        budget_data_previous_year = budget_data(@year - 1, 'amount_per_inhabitant', false)
        position = budget_data[:position].to_i
        sign = sign(budget_data[:value], budget_data_previous_year[:value])

        respond_to do |format|
          format.json do
            render json: {
              sign: sign,
              title: "#{@category_name} por habitante",
              value: format_currency(budget_data[:value]),
              delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
              ranking_position: position,
              ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 0),
              ranking_url: gobierto_budgets_places_ranking_path(@year,@kind,@area,'amount_per_inhabitant',@code.parameterize,page: GobiertoBudgets::Ranking.page_from_position(position), ine_code: params[:ine_code])
            }.to_json
          end
        end
      end

      def budget_percentage_over_total
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @code = params[:code]

        begin
          result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: @area, id: [params[:ine_code],@year,@code,@kind].join('/')
          amount = result['_source']['amount'].to_f

          result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast, type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [params[:ine_code], @year, BudgetLine::EXPENSE].join('/')
          total_amount = result['_source']['total_budget'].to_f

          percentage = (amount.to_f * 100)/total_amount
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          percentage = 0
        end

        respond_to do |format|
          format.json do
            render json: {
              title: "Porcentaje sobre el total",
              value: "#{helpers.number_with_precision(percentage, precision: 2, strip_insignificant_zeros: true)}%",
              sign: sign(percentage)
            }.to_json
          end
        end
      end

      def ranking
        @year = params[:year].to_i
        @area = params[:area]
        @kind = params[:kind]
        @var = params[:variable]
        @code = params[:code]

        offset = 0
        max_results = 5

        if @code.present?
          @variable = (@var == 'amount') ? 'amount' : 'amount_per_inhabitant'
          results, total_elements = GobiertoBudgets::BudgetLine.for_ranking({year: @year,
                                                            area_name: @area,
                                                            kind: @kind,
                                                            code: @code,
                                                            variable: @variable,
                                                            offset: 0,
                                                            per_page: 5})
        else
          @variable = (@var == 'amount') ? 'total_budget' : 'total_budget_per_inhabitant'
          results, total_elements = GobiertoBudgets::BudgetTotal.for_ranking(@year, @variable, @kind, offset, max_results)
        end

        top = results.first
        title = ranking_title(@variable, @year, @kind, @code, @area)
        respond_to do |format|
          format.json do
            render json: {
              title: title,
              top_place_name: place_name(top['ine_code']),
              top_amount: helpers.number_to_currency(top[@variable], precision: 0, strip_insignificant_zeros: true),
              ranking_path: gobierto_budgets_places_ranking_path(@year, @kind, @area, @var, @code),
              ranking_url: gobierto_budgets_places_ranking_url(@year, @kind, @area, @var, @code),
              twitter_share: ERB::Util.url_encode(twitter_share(title, gobierto_budgets_places_ranking_url(@year, @kind, @area, @var, @code))),
              top_5: results.map {|r| { place_name: place_name(r['ine_code'])}}
            }.to_json
          end
        end
      end

      def total_budget_execution
        year = params[:year].to_i
        total_budget_data_planned = total_budget_data(year, 'total_budget', false)
        total_budget_data_executed = total_budget_data_executed(year, 'total_budget')
        diff = total_budget_data_executed[:value] - total_budget_data_planned[:value] rescue ""
        sign = sign(total_budget_data_executed[:value], total_budget_data_planned[:value])
        diff = format_currency(diff) if diff.is_a?(Float)

        respond_to do |format|
          format.json do
            render json: {
              title: 'Ejecución vs Presupuesto',
              sign: sign,
              delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data_executed[:value], total_budget_data_planned[:value]), precision: 2),
              value: diff
            }.to_json
          end
        end
      end

      def debt
        year = params[:year].to_i

        no_data_this_year = false
        debt_year = get_debt(year, params[:ine_code])
        if debt_year.nil?
          year -= 1
          debt_year = get_debt(year, params[:ine_code])
          no_data_this_year = year
        end
        debt_previous_year = get_debt(year - 1, params[:ine_code])
        sign = sign(debt_year, debt_previous_year)

        respond_to do |format|
          format.json do
            render json: {
              title: "Deuda viva",
              sign: nil,
              delta_percentage: helpers.number_with_precision(delta_percentage(debt_previous_year, debt_year), precision: 2),
              value: helpers.number_to_currency(debt_year, precision: 0, strip_insignificant_zeros: true),
              no_data_this_year: no_data_this_year
            }.to_json
          end
        end
      end

      def municipalities_population
        year = params[:year].to_i

        terms = [{term: { year: year }}]

        query = {
          sort: [
            { ine_code: { order: 'asc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: terms
                }
              }
            }
          },
          size: 10_000
        }

        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
          type: GobiertoBudgets::SearchEngineConfiguration::Data.type_population, body: query

        result = response['hits']['hits'].map{ |h| h['_source'] }

        respond_to do |format|
          format.json do
            render json: result.to_json
          end
          format.csv do
            csv =  CSV.generate do |csv|
              csv << result.first.keys
              result.each do |row|
                csv << row.values
              end
            end
            send_data csv, filename: "population-#{year}.csv"
          end
        end
      end

      def municipalities_debt
        year = params[:year].to_i

        terms = [{term: { year: year }}]

        query = {
          sort: [
            { ine_code: { order: 'asc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: terms
                }
              }
            }
          },
          size: 10_000
        }

        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
          type: GobiertoBudgets::SearchEngineConfiguration::Data.type_debt, body: query

        result = response['hits']['hits'].map{ |h| h['_source'].merge({'value' => h['_source']['value']*1_000}) }

        respond_to do |format|
          format.json do
            render json: result.to_json
          end
          format.csv do
            csv =  CSV.generate do |csv|
              csv << result.first.keys
              result.each do |row|
                csv << row.values
              end
            end
            send_data csv, filename: "debt-#{year}.csv"
          end
        end
      end

      def budgets
        year = params[:year].to_i
        kind = params[:kind]
        place = INE::Places::Place.find params[:ine_code]
        area_name = params[:area]

        query = {
          sort: [
            { 'code' => { order: 'asc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { year: year }},
                    {term: { ine_code: place.id }},
                    {term: { kind: kind }}
                  ]
                }
              }
            }
          },
          size: 10_000
        }
        area = area_name == 'economic' ? EconomicArea : FunctionalArea

        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                               type: area_name, body: query
        items = response['hits']['hits'].map do |h|
              h['_source'].merge({category: area.all_items[kind][h['_source']['code']]})
            end
        respond_to do |format|
          format.json do
            render json: items.to_json
          end
        end
      end

      def budget_execution_deviation
        year = params[:year].to_i
        kind = params[:kind]
        ine_code = params[:ine_code]
        total_budgeted = GobiertoBudgets::BudgetTotal.budgeted_for(ine_code,year,kind)
        total_executed = GobiertoBudgets::BudgetTotal.execution_for(ine_code,year,kind)
        deviation = total_executed - total_budgeted
        deviation_percentage = helpers.number_with_precision(delta_percentage(total_executed, total_budgeted), precision: 2)
        up_or_down = sign(total_executed, total_budgeted)
        evolution = deviation_evolution(ine_code, kind)

        heading = "Desviación de los #{kind_literal(kind)} en #{year.to_s}"
        respond_to do |format|
          format.json do
            render json: {
              deviation_heading: heading,
              deviation_summary: deviation_message(kind, up_or_down, deviation_percentage, deviation),
              deviation_percentage: deviation_percentage,
              "#{kind}": {
                total_budgeted: format_currency(total_budgeted),
                total_executed: format_currency(total_executed),
                evolution: evolution,
                evolution_to_s: evolution.to_json
              }
            }.to_json
          end
        end
      end

      private

      def get_debt(year, ine_code)
        id = "#{ine_code}/#{year}"

        begin
          value = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
            type: GobiertoBudgets::SearchEngineConfiguration::Data.type_debt, id: id
          value['_source']['value'] * 1000
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
        end
      end

      def ranking_title(variable, year, kind, code, area_name)
        title = ["Top"]
        title << ((kind == 'G') ? 'gastos' : 'ingresos')
        title << ((variable == 'total_budget' or variable == 'amount') ? 'totales' : 'por habitante')
        title << "en #{budget_line_denomination(area_name, code, kind)}" if code.present?
        title << "en el #{year}"
        title.join(' ')
      end

      def budget_data(year, field, ranking = true)
        ine_code = params[:ine_code].to_i

        opts = {year: year, code: @code, kind: @kind, area_name: @area, variable: field}
        results, total_elements = BudgetLine.for_ranking(opts)

        if ranking
          position = BudgetLine.place_position_in_ranking(opts.merge(ine_code: ine_code))
        else
          total_elements = 0
          position = 0
        end

        value = results.select {|r| r['ine_code'] == ine_code }.first.try(:[],field)

        return {
          value: value,
          position: position,
          total_elements: total_elements
        }
      end

      def budget_data_executed(year, field)
        id = "#{params[:ine_code]}/#{year}/#{@code}/#{@kind}"

        begin
          value = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, type: @area, id: id
          value = value['_source'][field]
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          value = nil
        end

        return {
          value: value
        }
      end


      def total_budget_data(year, field, ranking = true)
        query = {
          sort: [
            { field.to_sym => { order: 'desc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { year: year }},
                    {term: { kind: GobiertoBudgets::BudgetLine::EXPENSE }}
                  ]
                }
              }
            }
          },
          size: 10_000,
          _source: false
        }

        id = "#{params[:ine_code]}/#{year}/#{BudgetLine::EXPENSE}"

        if ranking
          response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast, type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, body: query
          buckets = response['hits']['hits'].map{|h| h['_id']}
          position = buckets.index(id) + 1 rescue 0
        else
          buckets = []
          position = 0
        end

        begin
          value = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast, type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: id
          value = value['_source'][field]
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          value = 0
        end

        return {
          value: value,
          position: position,
          total_elements: buckets.length
        }
      end

      def total_budget_data_executed(year, field)
        id = "#{params[:ine_code]}/#{year}/#{BudgetLine::EXPENSE}"

        begin
          value = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_executed, type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: id
          value = value['_source'][field]
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          value = nil
        end

        return {
          value: value
        }
      end

      def delta_percentage(value, old_value)
        return "" if value.nil? || old_value.nil?
        ((value.to_f - old_value.to_f)/old_value.to_f) * 100
      end

      def deviation_message(kind, up_or_down, percentage, diff)
        percentage = percentage.to_s.gsub('-', '')
        diff = format_currency(diff, true)
        messages = {
          income_up:   "Se ha ingresado un #{percentage}% (#{diff}) más de lo planeado",
          income_down: "Se ha ingresado un #{percentage}% (#{diff}) menos de lo planeado",
          expense_up:  "Se ha gastado un #{percentage}% (#{diff}) más de lo planeado",
          expense_down:"Se ha gastado un #{percentage}% (#{diff}) menos de lo planeado"
        }
        final_message = if (kind == GobiertoBudgets::BudgetLine::INCOME)
          up_or_down == "sign-up" ? messages[:income_up] : messages[:income_down]
        else
          up_or_down == "sign-up" ? messages[:expense_up] : messages[:expense_down]
        end
        final_message
      end

      def deviation_evolution(ine_code, kind)
        response_budgeted = GobiertoBudgets::BudgetTotal.budget_evolution_for(ine_code, GobiertoBudgets::BudgetTotal::BUDGETED, kind)
        response_executed = GobiertoBudgets::BudgetTotal.budget_evolution_for(ine_code, GobiertoBudgets::BudgetTotal::EXECUTED, kind)

        response_budgeted.map do |budgeted_result|
          year = budgeted_result['year']
          total_budgeted = budgeted_result['total_budget']
          total_executed = response_executed.select {|te| te['year'] == year }.first.try(:[],'total_budget')
          next unless total_executed.present?

          deviation = delta_percentage(total_executed,total_budgeted)
          {
            year: year,
            deviation: helpers.number_with_precision(deviation, precision: 2,separator:'.').to_f
          }
        end.reject(&:nil?)
      end

      def get_places(ine_codes)
        ine_codes.split(':').map {|code| INE::Places::Place.find code}
      end

      def respond_lines_to_json(data_line)
        respond_to do |format|
          format.json do
            render json: data_line.generate_json
          end
        end
      end

    end
  end
end
