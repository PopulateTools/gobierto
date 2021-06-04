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
      datasets_published = @site.datasets.visibles.size
      assert_equal datasets_published, catalog[:datasets].size
    end

    def test_structure_catalog_building_using_site_with_datasets
      catalog = @subject.build_catalog
      assert catalog.has_key? :identifier_uri
      @site.configuration.available_locales.each do |locale|
        assert catalog.has_key? "title_#{locale}".to_sym
        assert catalog.has_key? "description_#{locale}".to_sym
      end
      assert catalog.has_key? :issued
      assert catalog.has_key? :modified
      assert catalog.has_key? :homepage
      assert catalog.has_key? :publisher
      assert catalog.has_key? :spatials
      assert catalog.has_key? :theme
      assert catalog.has_key? :datasets
      catalog[:datasets].each do |dataset|
        assert dataset.has_key? :url
        @site.configuration.available_locales.each do |locale|
          assert dataset.has_key? "title_#{locale}".to_sym
          assert dataset.has_key? "description_#{locale}".to_sym
        end
        assert dataset.has_key? :keywords
        assert dataset.has_key? :issued
        assert dataset.has_key? :modified
        assert dataset.has_key? :update_frequency
        assert dataset.has_key? :update_frequency_in_days
        assert dataset.has_key? :license_url
        assert dataset.has_key? :distributions
        dataset[:distributions].each do |distribution|
          @site.configuration.available_locales.each do |locale|
            assert distribution.has_key? "title_#{locale}_extended".to_sym
          end
          assert distribution.has_key? :format
          assert distribution.has_key? :download_url
          assert distribution.has_key? :csv_size
        end
      end
    end

    def test_structure_catalog_building_using_site_without_datasets
      catalog = @other_subject.build_catalog
      assert_equal 0, catalog[:datasets].size
    end
  end
end
