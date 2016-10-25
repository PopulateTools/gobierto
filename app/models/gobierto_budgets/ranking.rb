module GobiertoBudgets
  class Ranking
    # This class is used in the ranking table to provide the information for each row
    class Item < OpenStruct
    end

    def self.per_page
      25
    end

    def self.position(i, page)
      (page - 1)*self.per_page + i + 1
    end

    def self.page_from_position(position)
      return 1 if position.nil? || position < 1
      (position.to_f / self.per_page.to_f).ceil
    end

    def self.query(options)
      year = options[:year]
      variable = options[:variable]
      kind = options[:kind]
      page = options[:page]
      code = options[:code]
      filters = options[:filters]

      offset = (page-1)*self.per_page

      results, total_results = if code
        self.budget_line_ranking(options, offset)
      elsif variable == 'population'
        self.population_ranking(variable, year, offset, filters)
      else
        self.total_budget_ranking(variable, year, kind, offset, filters)
      end

      Kaminari.paginate_array(results, {limit: self.per_page, offset: offset, total_count: total_results})
    end

    # Returns the position of a place in a ranking. The ranking is determined by the variable
    # parameter
    def self.place_position(options)
      year = options[:year]
      ine_code = options[:ine_code]
      code = options[:code]
      kind = options[:kind]
      variable = options[:variable]
      filters = options[:filters]

      if code.present?
        return BudgetLine.place_position_in_ranking(options)
      else
        if variable == 'population'
          return Population.place_position_in_ranking(year, ine_code, filters)
        else
          variable = (variable == 'amount') ? 'total_budget' : 'total_budget_per_inhabitant'
          return BudgetTotal.place_position_in_ranking(year, variable, ine_code, kind, filters)
        end
      end
    end

    ## Private

    def self.budget_line_ranking(options, offset)

      results, total_elements = BudgetLine.for_ranking(options.merge(offset: offset, per_page: self.per_page))

      places_ids = results.map {|h| h['ine_code']}
      population_results = Population.for_places(places_ids, options[:year])

      places_ids = results.map{|h| h['ine_code']}
      total_results = BudgetTotal.for_places(places_ids, options[:year])

      return results.map do |h|
        id = h['ine_code']
        Item.new({
          place: INE::Places::Place.find(id),
          population: population_results.detect{|h| h['ine_code'] == id}.try(:[],'value'),
          amount_per_inhabitant: h['amount_per_inhabitant'],
          amount: h['amount'],
          total: total_results.detect{|h| h['ine_code'] == id}['total_budget']
        })
      end, total_elements
    end

    def self.population_ranking(variable, year, offset, filters)

      results, total_elements = Population.for_ranking(year,offset,self.per_page,filters)

      places_ids = results.map{|h| h['ine_code']}
      total_results = BudgetTotal.for_places(places_ids, year)

      return results.map do |h|
        id = h['ine_code']
        Item.new({
          place: INE::Places::Place.find(id),
          population: h['value'],
          amount_per_inhabitant: total_results.detect{|h| h['ine_code'] == id}['total_budget_per_inhabitant'],
          amount: total_results.detect{|h| h['ine_code'] == id}['total_budget'],
          total: total_results.detect{|h| h['ine_code'] == id}['total_budget']
        })
      end, total_elements
    end

    def self.total_budget_ranking(variable, year, kind, offset, filters)
      variable = if variable == 'amount'
                   'total_budget'
                 else
                   'total_budget_per_inhabitant'
                 end

      results, total_elements = BudgetTotal.for_ranking(year, variable, kind, offset, self.per_page, filters)

      places_ids = results.map {|h| h['ine_code']}
      population_results = Population.for_places(places_ids, year)

      return results.map do |h|
        id = h['ine_code']
        Item.new({
          place: INE::Places::Place.find(id),
          population: population_results.detect{|h| h['ine_code'] == id}.try(:[],'value'),
          amount_per_inhabitant: h['total_budget_per_inhabitant'],
          amount: h['total_budget'],
          total: h['total_budget']
        })
      end, total_elements
    end
  end
end
