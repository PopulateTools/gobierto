class GobiertoCommon::AlgoliaReindexJob < ActiveJob::Base
  queue_as :algoliasearch

  def perform(record, remove)
    if remove
      index = Algolia::Index.new(record.class.search_index_name)
      index.delete_object(record.id)
    else
      record.index!
    end
  end
end
