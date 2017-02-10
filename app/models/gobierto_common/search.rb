module GobiertoCommon
  class Search
    def initialize(site)
      @site = site
    end
    def search_in_indexes
      add_quotes = -> x{"'#{x}'"}

      models_to_search.map do |model|
        model.search_index_name
      end.map(&add_quotes).join(',')
    end

    attr_reader :site

    private

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
  end
end
