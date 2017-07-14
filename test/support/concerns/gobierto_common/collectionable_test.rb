module GobiertoCommon::CollectionableTest
  def test_remove_cleans_collection_items
    perform_enqueued_jobs do
      collectionable_object.destroy
    end
    assert GobiertoCommon::CollectionItem.where(item: collectionable_object).empty?
  end
end
