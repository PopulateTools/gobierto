# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class DatasetPresenterTest < ActiveSupport::TestCase

    def setup
      super
      @site = sites(:madrid)
      @subject = DatasetPresenter.new(@site)
      @other_site = sites(:huesca)
      @other_subject = DatasetPresenter.new(@other_site)
    end

    def test_structure_catalog_building_do_not_show_draft_datasets
      catalog = @subject.build_catalog
      datasets_published = GobiertoData::Dataset.by_site(@site.id).visibles.size
      assert_equal datasets_published, catalog[:datasets].size
    end

    def test_structure_catalog_building_using_site_with_datasets
      catalog = @subject.build_catalog
      assert catalog.has_key? :identifier_uri
      assert catalog.has_key? :title
      assert catalog.has_key? :description
      assert catalog.has_key? :issued
      assert catalog.has_key? :modified
      assert catalog.has_key? :language
      assert catalog.has_key? :homepage
      assert catalog.has_key? :datasets
      catalog[:datasets].each do |dataset|
        assert dataset.has_key? :url
        assert dataset.has_key? :title
        assert dataset.has_key? :description
        assert dataset.has_key? :issued
        assert dataset.has_key? :modified
        assert dataset.has_key? :languages
        assert dataset.has_key? :publisher
        assert dataset.has_key? :publisher_mbox
        assert dataset.has_key? :distributions
        dataset[:distributions].each do |distribution|
          assert distribution.has_key? :format
          assert distribution.has_key? :download_url
        end
      end
    end

    def test_structure_catalog_building_using_site_without_datasets
      catalog = @other_subject.build_catalog
      assert_equal 0, catalog[:datasets].size
    end
  end
end
