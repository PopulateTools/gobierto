module GobiertoData
  class DatasetPresenter
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TranslationHelper

    attr_reader :site

    def initialize(site)
      @site = site
    end

    def build_catalog
      catalog = {
        identifier_uri: url_helpers.gobierto_data_root_url(host: site.domain),
        title:          I18n.t('presenters.gobierto_data.catalog.title',site: site),
        description:    I18n.t('presenters.gobierto_data.catalog.description',site: site, publisher_url: url_helpers.gobierto_data_root_url(host: site.domain)),
        issued:         site.created_at,
        modified:       site.updated_at,
        language:       site_locale,
        homepage:       url_helpers.gobierto_data_root_url(host: site.domain),
        datasets:       build_datasets_for_catalog
      }
    end

    private

    def build_datasets_for_catalog
      site.datasets.visibles.map do |dataset|
        build_dataset_for_catalog(dataset)
      end
    end

    def build_dataset_for_catalog(dataset)
      {
        url:            url_helpers.gobierto_data_datasets_url(host: site.domain, id: dataset.slug),
        title:          dataset.name,
        description:    description_custom_field_record(dataset),
        issued:         dataset.created_at,
        modified:       dataset.updated_at,
        languages:      [site_locale],
        publisher:      site.name,
        publisher_mbox: site.reply_to_email,
        distributions:  build_distribution_for_catalog(dataset)
      }
    end

    def build_distribution_for_catalog(dataset)
      [
        {
          format:       'application/csv',
          download_url: url_helpers.download_gobierto_data_api_v1_dataset_url(slug: dataset.slug, host: site.domain)
        }
      ]
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    def site_locale
      site.configuration.default_locale
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
