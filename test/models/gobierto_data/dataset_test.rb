# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class DatasetTest < ActiveSupport::TestCase
    def subject
      @subject ||= gobierto_data_datasets(:users_dataset)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_valid
      assert subject.valid?
    end
  end
end
