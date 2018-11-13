# frozen_string_literal: true

require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def item
    @item ||= gobierto_cms_pages(:site_news_1)
  end

  def test_trigger_reindex_job
    # This mock sets the expectation of calling perform_later just once
    GobiertoCommon::AlgoliaReindexJob.expects(:perform_later).returns(true)
    item.class.trigger_reindex_job(item, false)

    # The second time the reindex job is called doesn't call algolia reindex job
    site.configuration.raw_configuration_variables = <<-YAML
algolia_search_disabled: true
    YAML
    site.save
    item.reload

    item.class.trigger_reindex_job(item, false)
  end

end
