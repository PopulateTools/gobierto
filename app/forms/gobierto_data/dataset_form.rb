# frozen_string_literal: true

module GobiertoData
  class DatasetForm < BaseForm
    include ::GobiertoCore::TranslationsHelpers
    include ActiveModel::Serialization

    attr_accessor(
      :site_id,
      :data_path
    )

    attr_writer(
      :id,
      :table_name,
      :name_translations,
      :schema,
      :csv_separator,
      :name,
      :slug,
      :append
    )

    validates :table_name, :name, presence: true
    validates :name_translations, translated_attribute_presence: true

    delegate :persisted?, to: :resource

    def resource
      @resource ||= resource_class.find_by(id: @id) || build_resource
    end
    alias dataset resource

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def id
      @id ||= resource.id
    end

    def table_name
      @table_name ||= resource.table_name
    end

    def name_translations
      @name_translations ||= begin
                               (resource.name_translations || available_locales_blank_translations).tap do |translations|
                                 translations[I18n.locale] = @name if @name.present?
                               end
                             end
    end

    def name
      name_translations[I18n.locale]
    end

    def save
      save_resource if valid?
    end

    def csv_separator
      @csv_separator ||= ","
    end

    def schema
      @schema ||= {}
    end

    def slug
      @slug ||= resource.slug
    end

    private

    def build_resource
      resource_class.new
    end

    def resource_class
      Dataset
    end

    def save_resource
      @resource = resource.tap do |attributes|
        attributes.site_id = site.id
        attributes.table_name = table_name
        attributes.name_translations = name_translations
        attributes.slug = slug
      end

      if @resource.save && load_data
        @resource
      else
        promote_errors(@resource.errors)
        false
      end
    end

    def load_data
      return unless data_path.present?

      temp_file = Tempfile.new(["data", ".csv"])
      begin
        temp_file.write(URI.open(data_path).read.encode("UTF-8"))
        @load_status = @resource.load_data_from_file(temp_file.path, csv_separator: csv_separator, schema_file: schema)
        @schema = @load_status[:schema]
        if @load_status[:db_result].has_key?(:errors)
          errors.add(:schema, @load_status[:db_result][:errors].map { |error| error[:sql] }.join("\n"))
          false
        else
          true
        end
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

  end
end
