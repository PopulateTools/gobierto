module GobiertoCommon
  class Search
    def initialize(site)
      @site = site
    end

    def search(query)
      results = Algolia.multiple_queries(build_queries(query))
      results['results']
    end

    private

    attr_reader :site

    def modules_to_search
      @modules_to_search ||= site.configuration.modules.map(&:constantize)
    end

    def models_to_search
      modules_to_search.map do |gobierto_module|
        if gobierto_module.respond_to?(:searchable_models)
          gobierto_module.searchable_models
        end
      end.flatten.compact
    end

    def build_queries(query)
      models_to_search.map do |model|
        {index_name: model.search_index_name, query: query, filters: "site_id:#{site.id}"}
      end
    end
  end
end
