# frozen_string_literal: true

class GobiertoCommon::AlgoliaReindexJob < ActiveJob::Base
  queue_as :algoliasearch

  def perform(klass_name, id, remove)
    klass = klass_name.constantize
    if remove
      index = Algolia::Index.new(klass.search_index_name)
      index.delete_object(id)
    else
      if record = klass.find_by(id: id)
        record.index!
      end
    end
  end
end
