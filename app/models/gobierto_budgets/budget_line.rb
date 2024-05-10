# frozen_string_literal: true

module GobiertoBudgets
  class BudgetLine < OpenStruct
    class RecordNotFound < StandardError; end
    class InvalidSearchConditions < StandardError; end

    include ActiveModel::Model
    include BudgetLineElasticsearchHelpers
    include BudgetLinePgSearchHelpers

    INCOME = "I"
    EXPENSE = "G"

    attr_reader(
      :id,
      :index,
      :type,
      :site,
      :area,
      :kind,
      :code,
      :organization_id,
      :ine_code,
      :province_id,
      :autonomy_id,
      :year,
      :amount,
      :amount_per_inhabitant,
      :level,
      :parent_code,
      :category,
      :name,
      :description
    )

    def self.all_kinds
      [INCOME, EXPENSE]
    end

    def self.get_level(code)
      code_segments = code.split("-")
      code_segments.length == 1 ? code_segments.first.length : code_segments.first.length + 1
    end

    def self.get_parent_code(code)
      if get_level(code) == 1
        nil
      else
        code_segments = code.split("-")
        code_segments.length == 1 ? code_segments.first.chop : code_segments.first
      end
    end

    def self.get_population(organization_id, year)
      population = execute_get_population_query(organization_id, year)

      if population.nil?
        previous_year_population = execute_get_population_query(organization_id, year - 1)
        next_year_population = execute_get_population_query(organization_id, year + 1)

        population = if previous_year_population && next_year_population
                       (previous_year_population + next_year_population) / 2
                     else
                       previous_year_population || next_year_population
                     end
      end

      population
    end

    def self.execute_get_population_query(organization_id, census_year)
      result = GobiertoBudgets::SearchEngine.client.get(
        index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.index,
        type: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.type_population,
        id: "#{ organization_id }/#{ census_year }"
      )
      result["_source"]["value"]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    # BudgetLine.new(site: Site.second, index: 'index_forecast', area_name: 'economic', kind: 'G', code: '1', year: 2015, amount: 123.45)
    def initialize(params = {})
      @site = params[:site]
      @index = params[:index]
      @area = BudgetArea.klass_for(params[:area_name])
      @kind = params[:kind]
      @code = params[:code]
      @year = params[:year]
      @amount = params[:amount].round(2)

      place = site.place
      @organization_id = site.organization_id
      @ine_code = place ? place.id.to_i : nil
      @id = "#{ organization_id }/#{ year }/#{ code }/#{ kind }"
      @category = Category.find_by(site: site, area_name: area.area_name, kind: kind, code: code)
      @name = get_name
      @description = get_description
      @province_id = place ? place.province_id.to_i : nil
      @autonomy_id = place ? place.province.autonomous_region_id.to_i : nil
      @level = self.class.get_level(code)
      @parent_code = self.class.get_parent_code(code)
      @amount_per_inhabitant = population ? (amount / population).round(2) : nil
    end

    def population
      @population ||= self.class.get_population(organization_id, year)
    end

    # TODO: remove?
    # def to_param
    #   { organization_id: organization_id, year: year, code: code, area_name: area.area_name, kind: kind }
    # end

    def save
      result = GobiertoBudgets::SearchEngine.client.index(index: elastic_search_index, type: area.area_name, id: id, body: elasticsearch_as_json.to_json)
      saved = (result["_shards"]["failed"] == 0)
      self.class.pg_search_reindex(self) if saved
      saved
    end

    def destroy
      self.class.pg_search_delete_index(self)
      result = GobiertoBudgets::SearchEngine.client.delete(index: elastic_search_index, type: area.area_name, id: id)
      result["_shards"]["failed"] == 0
    end

    private

    def get_name
      (category ? category.name : GobiertoBudgets::Category.default_name(area, kind, code))
    end

    def get_description
      (category ? category.description : GobiertoBudgets::Category.default_description(area, kind, code))
    end
  end
end
