module GobiertoCommon
  module Collectionable
    extend ActiveSupport::Concern

    included do
      after_destroy :clean_collection_items
    end

    private

    def clean_collection_items
      GobiertoCommon::CleanCollectionItemsJob.perform_later(self.site_id, self.class.name, self.id)
    end
  end
end
