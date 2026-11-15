# frozen_string_literal: true

module GobiertoBudgets
  # Expires the years with budgets data that GobiertoBudgetsData caches for every site,
  # so a budgets import that adds a year shows it
  class ClearYearsCache
    def call
      Rails.cache.delete_matched(matcher)
    end

    private

    def cache_key_prefix
      GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.name.underscore
    end

    # Redis only accepts glob patterns; the other stores need a regular expression
    def matcher
      if Rails.cache.is_a?(ActiveSupport::Cache::RedisCacheStore)
        "#{cache_key_prefix}/*"
      else
        %r{\A#{Regexp.escape(cache_key_prefix)}/}
      end
    end
  end
end
