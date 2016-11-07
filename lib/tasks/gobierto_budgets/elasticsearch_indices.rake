namespace :gobierto_budgets do
  namespace :elasticsearch do
    desc "Create indices"
    task create_indices: :environment do
      exit unless allowed?

      indices.each do |index|
        unless GobiertoBudgets::SearchEngine.client.indices.exists? index: index
          puts "== Creating #{index} index =="
          GobiertoBudgets::SearchEngine.client.indices.create index: index
        end
      end
    end

    desc "Drop indices"
    task drop_indices: :environment do
      exit unless allowed?

      indices.each do |index|
        if GobiertoBudgets::SearchEngine.client.indices.exists? index: index
          puts "== Deleting #{index} index =="
          GobiertoBudgets::SearchEngine.client.indices.delete index: index
        end
      end
    end

    def allowed?
      Rails.env.development? || Rails.env.test?
    end

    def indices
      [
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed,
        GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index,
        GobiertoBudgets::SearchEngineConfiguration::Data.index
      ]
    end
  end
end
