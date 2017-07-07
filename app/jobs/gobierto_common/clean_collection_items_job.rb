class GobiertoCommon::CleanCollectionItemsJob < ActiveJob::Base
  queue_as :default

  def perform(site_id, klass_name, id)
    site = Site.find site_id
    GobiertoCommon::CollectionItem.where(site_id: site.id, item_type: klass_name, item_id: id).destroy_all
  end
end
