# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class QueryFormTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:janet)
    end

    def subject
      @subject ||= QueryForm
    end

    def dataset
      @dataset ||= gobierto_data_datasets(:events_dataset)
    end

    def query
      @query ||= gobierto_data_queries(:users_count_query)
    end

    def valid_attributes
      @valid_attributes ||= {
        site_id: site.id,
        dataset_id: dataset.id,
        user_id: user.id,
        name_translations: { es: "Nueva query", en: "New query" },
        name: "New query",
        privacy_status: "open",
        sql: "select count(*) from users where census_verified"
      }
    end

    def test_create_new_with_valid_attributes
      form = subject.new(valid_attributes)

      assert form.valid?

      assert_difference "GobiertoData::Query.count", 1 do
        assert form.save
      end

      item = form.query

      assert item.persisted?
      assert "New query", item.name
      assert "Nueva query", item.name_es
      assert item.open?
      assert user, item.user
      assert dataset, item.dataset
    end

    def test_update_with_valid_attributes
      form = subject.new(valid_attributes.merge(id: query.id))

      assert form.valid?

      assert_no_difference "GobiertoData::Query.count" do
        assert form.save
      end

      item = form.query

      assert item.persisted?
      assert query.id, item.id
      assert "New query", item.name
      assert "Nueva query", item.name_es
      assert item.open?
      assert user, item.user
      assert dataset, item.dataset
    end

    def test_validate_sql
      form = subject.new(valid_attributes.merge(sql: "select * from not_existing_table"))

      refute form.valid?
      assert form.errors[:sql].present?
      assert_match(/PG::UndefinedTable: ERROR:  relation \"not_existing_table\" does not exist/, form.errors[:sql].join("\n"))
    end

    def test_name_is_ignored_if_name_translations_present
      form = subject.new(valid_attributes.merge(name: "WADUS"))

      assert form.save
      assert form.query.name_translations.values.exclude? "WADUS"
    end

    def test_name_is_converted_to_translation
      form = subject.new(valid_attributes.except(:name_translations).merge(name: "WADUS"))

      assert form.save
      assert_equal "WADUS", form.query.name_en
    end

    def test_privacy_status_open_by_default
      form = subject.new(valid_attributes.except(:name_translations).merge(name: "WADUS"))

      assert form.save
      assert form.query.open?
    end

    def test_invalid_missing_attributes
      form = subject.new(valid_attributes.except(:site_id, :dataset_id, :user_id, :sql, :name, :name_translations))

      refute form.valid?
      %w(site dataset user sql name_translations).each do |attribute|
        assert form.errors[attribute].include? "can't be blank"
      end
    end
  end
end
