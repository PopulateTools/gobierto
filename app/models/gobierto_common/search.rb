module GobiertoCommon
  class Search

    attr_reader :site, :current_module_class

    def self.algoliasearch_configured?
      s = Rails.application.secrets

      s.algolia_application_id.present? &&
      s.algolia_api_key.present? &&
      s.algolia_search_api_key.present?
    end

    def initialize(site, current_module_class=nil)
      @site = site
      @current_module_class = current_module_class || GobiertoCms
    end

    def search_in_indexes
      add_quotes = -> x{"'#{x}'"}

      models_to_search.map do |model|
        model.search_index_name
      end.map(&add_quotes).join(',')
    end

    private

    def modules_to_search
      @modules_to_search ||= begin
        modules_classes = (site.configuration.modules + site.configuration.default_modules).map(&:constantize)
        modules_classes.delete(current_module_class)
        modules_classes.unshift(current_module_class) # make current module results appear first
      end
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
