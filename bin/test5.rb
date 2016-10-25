CSV.open("fiestas-populares.csv", "wb") do |csv|
  csv << %W{ codigo_ine_municipio nombre_municipio codigo_ine_provincia codigo_ine_autonomia valor_2010_p valor_2011_p valor_2012_p valor_2013_p valor_2014_p valor_2015_p valor_2010_e valor_2011_e valor_2012_e valor_2013_e valor_2014_e valor_2015_e }

  INE::Places::Place.all.each do |place|
    values_p = []
    values_e = []
    (2010..2015).each do |year|
      id = [place.id, year, '338', 'G'].join('/')
      begin
        response = GobiertoBudgets::SearchEngine.client.get(index: 'budgets-forecast-v2', type: 'functional', id: id)
        values_p.push response['_source']['amount']
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        values_p.push nil
      end

      begin
        response = GobiertoBudgets::SearchEngine.client.get(index: 'budgets-execution-v2', type: 'functional', id: id)
        values_e.push response['_source']['amount']
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        values_e.push nil
      end
    end

    csv << ([place.id, place.name, place.province.id, place.province.autonomous_region.id] + values_p + values_e)
  end
end

