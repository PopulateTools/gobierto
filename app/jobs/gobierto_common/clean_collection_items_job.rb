class GobiertoCommon::CleanCollectionItemsJob < ActiveJob::Base
  queue_as :default

  def perform(klass_name, id)
    GobiertoCommon::CollectionItem.where(item_type: klass_name, item_id: id).destroy_all
  end
end
