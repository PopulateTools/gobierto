# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class DatasetTest < ActiveSupport::TestCase
    attr_accessor :module_settings, :default_settings
    def setup
      super

      @module_settings = site.module_settings.find_by(module_name: "GobiertoData")
      @default_settings = module_settings.settings
    end

    def subject
      @subject ||= gobierto_data_datasets(:users_dataset)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_valid
      assert subject.valid?
    end

    def test_default_limit
      # api limit is set to 10 and size is 15.0
      assert_equal 50, subject.default_limit
    end

    def test_default_limit_with_limit_zero
      module_settings.update_attribute(:settings, default_settings.merge("api_settings" => { "max_dataset_size_for_queries" => 0 }))

      # api limit is set to 0 and size is 15.0
      assert_nil subject.default_limit
    end

    def test_defaul_limit_with_no_api_configuration
      module_settings.update_attribute(:settings, default_settings.merge("api_settings" => {}))

      # api limit is not set and size is 15.0 (default is 2)
      assert_equal 50, subject.default_limit
    end
  end
end
