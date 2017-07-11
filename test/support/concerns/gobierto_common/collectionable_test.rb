module GobiertoCommon::CollectionableTest
  def test_remove_cleans_collection_items
    perform_enqueued_jobs do
      collectionable_object.destroy
    end
    assert GobiertoCommon::CollectionItem.where(site: collectionable_object.site, item: collectionable_object).empty?
  end
end
