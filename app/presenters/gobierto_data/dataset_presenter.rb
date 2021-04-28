module GobiertoData
  class DatasetPresenter
    include ActionView::Helpers::UrlHelper

    attr_reader :site

    def initialize(site)
      @site = site
    end

    def build_catalog
      catalog = {
        identifier_uri: url_helpers.gobierto_data_root_url(host: site.domain),
        title:          "dcat catalog for #{site}",
        description:    "this is catalog published by #{@catalog_identifier_uri} which contains datasets",
        issued:         site.created_at,
        modified:       GobiertoData::Dataset.where(site_id: site.id).maximum(:created_at) || site.created_at,
        languages:      site["configuration_data"]["available_locales"],
        homepage:       url_helpers.gobierto_data_root_url(host: site.domain),
        license_url:    "https://opendatacommons.org/licenses/odbl/",
        datasets:       build_datasets_for_catalog
      }
    end

    private

    def build_datasets_for_catalog
      datasets = []
      Dataset.where(site_id: site.id).visibles.each do |dataset|
        datasets <<  build_dataset_for_catalog(dataset)
      end
      datasets
    end

    def build_dataset_for_catalog(dataset)
      {
        url: url_helpers.gobierto_data_datasets_url(host: site.domain, id: dataset.slug),
        title: dataset.name,
        description: description_custom_field_record(dataset),
        keywords: [],
        issued: dataset.created_at,
        modified: dataset.updated_at,
        languages: [site_locale],
        license_url: "https://opendatacommons.org/licenses/odbl/",
        publisher:  site.name,
        publisher_mbox: site.reply_to_email,
        distributions: build_distribution_for_catalog(dataset)
      }
    end

    def build_distribution_for_catalog(dataset)
      [
        {
          format: 'application/csv',
          download_url: url_helpers.download_gobierto_data_api_v1_dataset_url(dataset, host: site.domain)
        }
      ]
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    def site_locale
      site.configuration_data["default_locale"]
    end

    def description_custom_field_record(dataset)
      if dataset.custom_field_record_with_uid("description")
        dataset.custom_field_record_with_uid("description").payload["description"][site_locale]
      else
        ""
      end
    end
  end
end
