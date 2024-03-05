# frozen_string_literal: true

module GobiertoCommon
  class CustomField < ApplicationRecord
    include GobiertoCommon::Sortable

    belongs_to :site
    belongs_to :instance, polymorphic: true, optional: true
    has_many :records, dependent: :destroy, class_name: "CustomFieldRecord"
    validates :name, presence: true
    validates :uid, uniqueness: { scope: [:site_id, :class_name, :instance] }

    enum field_type: { localized_string: 0,
                       string: 1,
                       localized_paragraph: 2,
                       paragraph: 3,
                       single_option: 4,
                       multiple_options: 5,
                       color: 6,
                       image: 7,
                       date: 8,
                       vocabulary_options: 9,
                       plugin: 10,
                       numeric: 11 }

    scope :sorted, -> { order(position: :asc) }
    scope :with_md, -> { where(field_type: [:paragraph, :localized_paragraph]) }
    scope :localized, -> { where(field_type: [:localized_string, :localized_paragraph]) }
    scope :not_localized, -> { where.not(field_type: [:localized_string, :localized_paragraph]) }
    scope :with_plugin_type, ->(plugin_type) { plugin.where("options @> ?", { configuration: { plugin_type: plugin_type } }.to_json) }
    scope :for_class, ->(klass) { klass.present? ? where(class_name: klass.name).all : all }
    scope :for_vocabulary, ->(vocabulary) { where("options @> ?", { vocabulary_id: vocabulary.id.to_s }.to_json) }
    scope :table_with_decorator, lambda { |decorator|
      with_plugin_type("table").where(
        "options @> ?",
        { configuration: { plugin_configuration: { category_term_decorator: decorator } } }.to_json
      )
    }

    translates :name

    before_create :set_uid, :set_position
    after_validation :check_depending_uids

    def self.field_types_with_options
      field_types.select { |key, _| /option/.match(key) }
    end

    def self.field_types_with_vocabulary
      field_types.select { |key, _| /vocabulary/.match(key) }
    end

    def self.available_vocabulary_options
      [:single_select, :multiple_select, :tags]
    end

    def self.csv_importable_field_types
      [:localized_string,
       :string,
       :localized_paragraph,
       :paragraph,
       :single_option,
       :multiple_options,
       :color,
       :image,
       :date,
       :vocabulary_options,
       :numeric]
    end

    def self.field_types_with_multiple_setting
      %w(image)
    end

    def self.date_options
      [:date, :datetime]
    end

    def self.unit_options
      [:generic, :currency]
    end

    def allow_multiple?
      self.class.field_types_with_multiple_setting.include? field_type
    end

    def multiple?
      allow_multiple? && configuration.multiple
    end

    def long_text?
      /paragraph/.match field_type
    end

    def csv_importable?
      self.class.csv_importable_field_types.include? field_type.to_sym
    end

    def self.searchable_fields
      [:localized_string, :string, :localized_paragraph, :paragraph]
    end

    def has_options?
      /option/.match?(field_type)
    end

    def has_vocabulary?
      if (plugin_type = configuration.plugin_type&.to_sym)
        self.class.has_vocabulary?(plugin_type)
      else
        /vocabulary/.match?(field_type)
      end
    end

    def has_localized_value?
      /localized/.match?(field_type)
    end

    def localized_options(locale)
      options.map do |id, translations|
        [translations[locale.to_s], id]
      end
    end

    def vocabulary_id
      return unless has_vocabulary? && options.present?

      options.dig "vocabulary_id"
    end

    def vocabulary
      site.vocabularies.find_by(id: vocabulary_id)
    end

    def configuration
      @configuration ||= OpenStruct.new(
        (options || {}).dig("configuration") || {}
      )
    end

    def refers_to?(custom_field)
      configuration.plugin_configuration.dig("custom_field_ids")&.include?(custom_field.id) ||
        configuration.plugin_configuration.dig("custom_field_uids")&.include?(custom_field.uid)
    end

    private

    def self.has_vocabulary?(plugin_type)
      CustomFieldPlugin.find(plugin_type)&.requires_vocabulary?
    end

    def set_uid
      self.uid ||= SecureRandom.uuid
    end

    def set_position
      self.position = begin
                        self.class.where(site_id: site_id, class_name: class_name).maximum(:position).to_i + 1
                      end
    end

    def check_depending_uids
      return unless changes[:uid].present?

      records.where("payload->>? IS NOT NULL", uid_was).each do |record|
        record.update_attribute(
          :payload,
          record.payload.tap do |hash|
            hash[uid] = hash.delete uid_was
          end
        )
      end
    end
  end
end
