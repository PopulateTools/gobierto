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

    def test_attachments_collection
      dataset = site.datasets.create(
        name_translations: { en: "Departments", es: "Departamentos" },
        table_name: "gp_departments"
      )

      assert dataset.attachments_collection.present?
      assert_equal dataset.attachments_collection, dataset.attachments_collection!
    end

    def test_attachments_collection!
      assert_nil subject.attachments_collection
      subject.attachments_collection!
      assert subject.attachments_collection.present?
      assert_equal subject.attachments_collection, subject.attachments_collection!
    end
  end
end
