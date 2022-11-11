# frozen_string_literal: true

module GobiertoBudgets
  module SearchEngineConfiguration
    class Year

      DEFAULT_LAST_YEAR_WITH_DATA = Date.today.year

      def self.last(force = false)
        return DEFAULT_LAST_YEAR_WITH_DATA if force || current_site.nil?

        cached(:last) do
          if current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_elaboration"]
            last_year_with_data - 1
          else
            last_year_with_data
          end
        end
      end

      def self.first
        2010
      end

      def self.all
        cached(:all) { last.downto(first).to_a }
      end

      def self.all_with_data
        cached(:all_with_data) { last_year_with_data.downto(first).to_a }
      end

      def self.with_data(params={})
        cached :with_data, params do
          all.select do |year|
            ::GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: year, index: params[:index])
          end
        end
      end

      def self.last_year_with_data
        (DEFAULT_LAST_YEAR_WITH_DATA + 1).downto(first) do |year|
          if GobiertoBudgets::BudgetLine.any_data?(site: current_site, index: ::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, year: year)
            return year
          end
        end

        DEFAULT_LAST_YEAR_WITH_DATA
      end

      # private class methods
      #
      def self.budgets_elaboration_disabled?
        current_site.gobierto_budgets_settings && !current_site.gobierto_budgets_settings.settings["budgets_elaboration"]
      end
      private_class_method :budgets_elaboration_disabled?

      def self.current_site
        GobiertoCore::CurrentScope.current_site
      end
      private_class_method :current_site

      def self.cached(method_name, args={})
        cache_key = "#{name.underscore}/#{method_name}/#{current_site&.id || 'global'}"
        cache_key += args.to_s if args.any?
        Rails.cache.fetch(cache_key) { yield }
      end
      private_class_method :cached

    end
  end
end
