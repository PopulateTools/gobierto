def perc(value,total)
  (value.to_f*100)/total.to_f
end

def perc_diff(v1,v2)
  ((v1.to_f - v2.to_f)/v2.to_f)*100
end

# INE::Places.hydratate INE::Places::Place, 'https://presupuestos.gobierto.es/api/data/population/2015.csv', id_column: 'ine_code', as: :population, value_column: 'value', convert_to: :integer
# INE::Places.hydratate INE::Places::Place, 'https://presupuestos.gobierto.es/api/data/debt/2015.csv', id_column: 'ine_code', as: :debt, value_column: 'value', convert_to: :float
#
# year = 2015
# CSV.open("explore-debt.csv", "wb") do |csv|
#   csv << %W{ year ine_code name province_id autonomous_region_id population debt budget_line_amount budget_line_amount_per_inhabitant total_budget total_budget_per_inhabitant }
#
#   INE::Places::Place.all.each do |place|
#     begin
#       id = [place.id, year, '0', 'G'].join('/')
#       response = GobiertoBudgets::SearchEngine.client.get(index: 'budgets-forecast-v2', type: 'functional', id: id)
#       budget_line_amount = response['_source']['amount']
#       budget_line_amount_per_inhabitant = response['_source']['amount_per_inhabitant']
#     rescue Elasticsearch::Transport::Transport::Errors::NotFound
#       budget_line_amount = nil
#       budget_line_amount_per_inhabitant = nil
#     end
#     begin
#       id = [place.id, year].join('/')
#       response = GobiertoBudgets::SearchEngine.client.get(index: 'budgets-forecast-v2', type: 'total-budget', id: id)
#       total_budget = response['_source']['total_budget']
#       total_budget_per_inhabitant = response['_source']['total_budget_per_inhabitant']
#       csv << [ year, place.id, place.name, place.province.id, place.province.autonomous_region.id, place.data.population, place.data.debt, budget_line_amount, budget_line_amount_per_inhabitant, total_budget, total_budget_per_inhabitant]
#     rescue Elasticsearch::Transport::Transport::Errors::NotFound
#     end
#   end
# end

CSV.open("debt-evolution.csv", "wb") do |csv|
  csv << %W{ year debt population }

  (2010..2015).each do |year|
    puts year
    INE::Places.hydratate INE::Places::Place, "https://presupuestos.gobierto.es/api/data/debt/#{year}.csv", id_column: 'ine_code', as: :debt, value_column: 'value', convert_to: :float
    INE::Places.hydratate INE::Places::Place, "https://presupuestos.gobierto.es/api/data/population/#{year}.csv", id_column: 'ine_code', as: :population, value_column: 'value', convert_to: :integer

    total_debt = 0
    total_population = 0
    INE::Places::Place.all.each do |place|
      if place.data.debt.present? && place.data.population.present?
        total_debt += place.data.debt
        total_population += place.data.population
      end
    end
    csv << [ year, total_debt, total_population]
  end
end

