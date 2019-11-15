# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    class DatasetForm < BaseForm

      attr_accessor(
        :id,
        :site_id,
        :name_translations,
        :table_name,
        :slug,
        :admin_id,
        :ip
      )

      validates :site_id, presence: true

      delegate :persisted?, to: :dataset

      def save
        save_dataset if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def dataset
        @dataset ||= dataset_class.find_by(id: id).presence || build_dataset
      end

      private

      def build_dataset
        dataset_class.new
      end

      def dataset_class
        ::GobiertoData::Dataset
      end

      def save_dataset
        @dataset = dataset.tap do |attributes|
          attributes.site_id = site_id
          attributes.name_translations = name_translations
          attributes.table_name = table_name
          attributes.slug = slug.blank? ? nil : slug
        end

        if @dataset.valid?
          @dataset.save

          @dataset
        else
          promote_errors(@dataset.errors)

          false
        end
      end

    end
  end
end
