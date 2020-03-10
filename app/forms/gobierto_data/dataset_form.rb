# frozen_string_literal: true

module GobiertoData
  class DatasetForm < BaseForm
    include ::GobiertoCore::TranslationsHelpers
    include ActiveModel::Serialization

    attr_accessor(
      :site_id,
      :data_path,
      :data_file
    )

    attr_writer(
      :id,
      :table_name,
      :name_translations,
      :schema,
      :schema_file,
      :csv_separator,
      :name,
      :slug,
      :append,
      :local_data,
      :visibility_level
    )

    validates :table_name, :name, :visibility_level, presence: true
    validates :name_translations, translated_attribute_presence: true
    validates :visibility_level, inclusion: { in: Dataset.visibility_levels.keys }

    delegate :persisted?, :data_updated_at, to: :resource

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
      @table_name.present? ? @table_name.parameterize.underscore : resource.table_name
    end

    def append
      @append ||= false
    end

    def local_data
      @local_data ||= false
    end

    def name_translations
      @name_translations ||= begin
                               (resource.name_translations || available_locales_blank_translations).tap do |translations|
                                 translations[I18n.locale] = @name if @name.present?
                               end
                             end
    end

    def name
      name_translations.with_indifferent_access[I18n.locale]
    end

    def visibility_level
      @visibility_level ||= "draft"
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

    def schema_file
      if @schema_file.present?
        @schema_file.tempfile.path
      else
        schema.is_a?(String) ? JSON.parse(schema) : schema
      end
    end

    def slug
      @slug ||= resource.slug
    end

    private

    def source_data
      if data_file.present?
        data_file.tempfile.rewind
        data_file.tempfile
      else
        local_data ? File.open(data_path, "r") : URI.open(data_path, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      end
    end

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
        attributes.visibility_level = visibility_level
      end

      if @resource.save && load_data
        @resource
      else
        promote_errors(@resource.errors)
        false
      end
    end

    def load_data
      return unless [data_file, data_path].any?(&:present?)

      temp_file = Tempfile.new(["data", ".csv"])
      begin
        temp_file.write(source_data.read.force_encoding("UTF-8"))
        temp_file.rewind
        @load_status = @resource.load_data_from_file(
          temp_file.path,
          csv_separator: csv_separator,
          schema_file: schema_file,
          append: append.is_a?(String) ? append == "true" : append
        )
        @schema = @load_status[:schema]
        if @load_status[:db_result].has_key?(:errors)
          errors.add(:schema, @load_status[:db_result][:errors].map { |error| error[:sql] }.join("\n"))
          false
        else
          true
        end
      rescue CSV::MalformedCSVError
        errors.add(data_file.present? ? :data_file : :data_path, "CSV file malformed or with wrong encoding (expected UTF-8)")
        false
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

  end
end
