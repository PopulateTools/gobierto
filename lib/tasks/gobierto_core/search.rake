# frozen_string_literal: true

namespace :gobierto_core do
  namespace :search do
    desc "Check indexes and create missing ones"
    task migrate_indexes: :environment do
      algolia_models = ActiveRecord::Base.descendants.select{ |model| model.respond_to?(:reindex) }
      algolia_models.each do |model|
        begin
          model.index.search "test"
        rescue Algolia::AlgoliaProtocolError
          puts "- Creating index for #{model.name}"
          model.reindex
        end
      end
    end
  end
end
