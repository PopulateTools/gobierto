# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class CacheTest < ActiveSupport::TestCase
    def dataset
      @dataset ||= gobierto_data_datasets(:users_dataset)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_etag_updated_by_updating_param
      etag_old = GobiertoData::Cache.etag("foo", site)
      etag_new = GobiertoData::Cache.etag("bar", site)
      refute_equal etag_old, etag_new
    end

    def test_last_modified_updated
      last_modified_old = nil
      Timecop.freeze(Time.zone.parse("2014-03-15")) do
        last_modified_old = GobiertoData::Cache.last_modified(site)
      end
      dataset.touch
      last_modified_new = GobiertoData::Cache.last_modified(site)
      refute_equal last_modified_old, last_modified_new
    end

    def test_current_site_datasets_cache_key_updated_when_dataset_updated
      old_key = GobiertoData::Cache.current_site_datasets_cache_key(site)
      dataset.touch
      new_key = GobiertoData::Cache.current_site_datasets_cache_key(site)

      refute_equal old_key, new_key
    end
  end
end
