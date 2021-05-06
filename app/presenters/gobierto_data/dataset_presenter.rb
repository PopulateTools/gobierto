module GobiertoData
  class DatasetPresenter
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TranslationHelper

    attr_reader :site

    def initialize(site)
      @site = site
    end

    def build_catalog
      Hash.new.tap do |catalog|
          catalog[:languages] = site.configuration.available_locales
          catalog[:identifier_uri] = url_helpers.gobierto_data_root_url(host: site.domain)
          site.configuration.available_locales.each do |locale|
            catalog["title_#{locale}".to_sym] = I18n.t('presenters.gobierto_data.catalog.title',site: site, locale: locale)
            catalog["description_#{locale}".to_sym] = I18n.t('presenters.gobierto_data.catalog.description',site: site, publisher_url: url_helpers.gobierto_data_root_url(host: site.domain), locale: locale)
          end
          catalog[:issued] = site.created_at.iso8601
          catalog[:modified] = site.updated_at.iso8601
          catalog[:homepage] = url_helpers.gobierto_data_root_url(host: site.domain)
          catalog[:publisher] = catalog_record_from_custom_field("catalog-publisher")
          catalog[:spatials] = catalog_record_from_custom_field("catalog-spatials")
          catalog[:theme] =  catalog_record_from_custom_field("catalog-theme-taxonomy")
          catalog[:datasets] = build_datasets_for_catalog
      end
    end

    private

    def build_datasets_for_catalog
      site.datasets.visibles.sorted_by_creation.map do |dataset|
        build_dataset_for_catalog(dataset)
      end
    end

    def build_dataset_for_catalog(dataset)
      Hash.new.tap do |dataset_presenter|
          dataset_presenter[:url] = url_helpers.gobierto_data_datasets_url(host: site.domain, id: dataset.slug)
          site.configuration.available_locales.each do |locale|
            dataset_presenter["title_#{locale}".to_sym]       = dataset.name(locale: locale)
            dataset_presenter["description_#{locale}".to_sym] = description_from_custom_field_record(dataset)[locale]
          end
          dataset_presenter[:keywords] = category_from_custom_field_record(dataset)
          dataset_presenter[:issued]   = dataset.created_at.iso8601
          dataset_presenter[:modified] = dataset.updated_at.iso8601
          dataset_presenter[:update_frequency] = frecuency_from_custom_field_record(dataset).first
          dataset_presenter[:update_frequency_in_days] =  frecuency_from_custom_field_record(dataset).last
          dataset_presenter[:license_url] = license_url_from_custom_field_record(dataset)
          dataset_presenter[:distributions] =  build_distribution_for_catalog(dataset)
      end
    end

    def build_distribution_for_catalog(dataset)
      [
        Hash.new.tap do |distribution|
          site.configuration.available_locales.each do |locale|
            distribution["title_#{locale}_extended".to_sym] = "#{dataset.name(locale: locale)} #{I18n.t('presenters.gobierto_data.catalog.at_format')} application/csv"
          end
          distribution[:format] = 'application/csv'
          distribution[:download_url] = url_helpers.download_gobierto_data_api_v1_dataset_url(slug: dataset.slug, host: site.domain)
          distribution[:csv_size] = dataset.size&.[](:csv)
        end
      ]
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    def site_locale
      site.configuration.default_locale
    end

    def description_from_custom_field_record(dataset)
      if dataset.custom_field_record_with_uid("description")
        dataset.custom_field_record_with_uid("description").payload["description"]
      else
        ""
      end
    end

    def license_url_from_custom_field_record(dataset)
      custom_field_record = dataset.custom_field_record_with_uid('dataset-license')
      if !custom_field_record.nil? && !custom_field_record.payload["dataset-license"].blank?
        site.terms.find_by(id: custom_field_record.payload["dataset-license"])[:description_translations][site_locale]
      else
        ""
      end
    end

    def category_from_custom_field_record(dataset)
      custom_field_record = dataset.custom_field_record_with_uid("category")
      if !custom_field_record.nil? && !custom_field_record.payload["category"].blank?
        site.terms.find_by(id: custom_field_record.payload["category"])[:name_translations]
      else
        ""
      end
    end

    def frecuency_from_custom_field_record(dataset)
      custom_field_record = dataset.custom_field_record_with_uid("frequency")
      if !custom_field_record.nil? && !custom_field_record.payload["frequency"].blank?
        term = site.terms.find_by(id: custom_field_record.payload["frequency"])
        [
          term[:name_translations]["en"],
          term[:description_translations]["en"]
        ]
      else
        ["", ""]
      end
    end

    def catalog_record_from_custom_field(uid)
      custom_field = site.custom_fields.find_by(uid: uid)
      if custom_field
        site.custom_field_records.find_by(custom_field_id: custom_field.id)&.payload["no-translatable"]
      else
        []
      end
    end

  end
end
