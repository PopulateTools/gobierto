# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  class CollectionTest < ActiveSupport::TestCase
    def process_collection
      @process_collection ||= gobierto_common_collections(:gender_violence_process_news)
    end

    def process_collection_container
      @process_collection_container ||= gobierto_participation_processes(:gender_violence_process)
    end

    def page
      @page ||= gobierto_cms_pages(:generic_site_page)
    end

    def test_append_in_a_process_collection
      assert_difference "GobiertoCommon::CollectionItem.count", 5 do
        process_collection.append(page)
      end

      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection.site)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container_type: "GobiertoParticipation")
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection.container)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection.container.scope)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection.container.issue)
    end

    def test_container
      assert_equal process_collection_container, process_collection.container
      assert_equal ::GobiertoParticipation, GobiertoCommon::Collection.new(container_type: "GobiertoParticipation").container
    end
  end
end
