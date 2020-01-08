# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class VisualizationFormTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def user
      @user ||= users(:janet)
    end

    def subject
      @subject ||= VisualizationForm
    end

    def query
      @query ||= gobierto_data_queries(:events_count_query)
    end

    def visualization
      @visualization ||= gobierto_data_visualizations(:users_count_visualization)
    end

    def valid_attributes
      @valid_attributes ||= {
        site_id: site.id,
        query_id: query.id,
        user_id: user.id,
        name_translations: { es: "Nueva visualización", en: "New visualization" },
        name: "New visualization",
        privacy_status: "open",
        spec: { a: 1, b: 2 }
      }
    end

    def test_create_new_with_valid_attributes
      form = subject.new(valid_attributes)

      assert form.valid?

      assert_difference "GobiertoData::Visualization.count", 1 do
        assert form.save
      end

      item = form.visualization

      assert item.persisted?
      assert "New visualization", item.name
      assert "Nueva visualización", item.name_es
      assert item.open?
      assert user, item.user
      assert query, item.query
    end

    def test_update_with_valid_attributes
      form = subject.new(valid_attributes.merge(id: visualization.id))

      assert form.valid?

      assert_no_difference "GobiertoData::Visualization.count" do
        assert form.save
      end

      item = form.visualization

      assert item.persisted?
      assert visualization.id, item.id
      assert "New visualization", item.name
      assert "Nueva visualización", item.name_es
      assert item.open?
      assert user, item.user
      assert query, item.query
    end

    def test_name_is_ignored_if_name_translations_present
      form = subject.new(valid_attributes.merge(name: "WADUS"))

      assert form.save
      assert form.visualization.name_translations.values.exclude? "WADUS"
    end

    def test_name_is_converted_to_translation
      form = subject.new(valid_attributes.except(:name_translations).merge(name: "WADUS"))

      assert form.save
      assert_equal "WADUS", form.visualization.name_en
    end

    def test_privacy_status_open_by_default
      form = subject.new(valid_attributes.except(:name_translations).merge(name: "WADUS"))

      assert form.save
      assert form.visualization.open?
    end

    def test_invalid_missing_attributes
      form = subject.new(valid_attributes.except(:site_id, :query_id, :user_id, :spec, :name, :name_translations))

      refute form.valid?
      %w(site query user spec name_translations).each do |attribute|
        assert form.errors[attribute].include? "can't be blank"
      end
    end
  end
end
