# frozen_string_literal: true

module GobiertoCommon
  class CustomField < ApplicationRecord
    include GobiertoCommon::Sortable

    belongs_to :site
    has_many :records, dependent: :destroy, class_name: "CustomFieldRecord"
    validates :name, presence: true

    enum field_type: { localized_string: 0,
                       string: 1,
                       localized_paragraph: 2,
                       paragraph: 3,
                       single_option: 4,
                       multiple_options: 5,
                       color: 6,
                       image: 7 }

    scope :sorted, -> { order(position: :asc) }
    scope :localized, -> { where(field_type: [:localized_string, :localized_paragraph]) }
    scope :not_localized, -> { where.not(field_type: [:localized_string, :localized_paragraph]) }

    translates :name

    before_create :set_uid, :set_position
    after_validation :check_depending_uids

    def self.field_types_with_options
      field_types.select { |key, _| /option/.match(key) }
    end

    def long_text?
      /paragraph/.match field_type
    end

    def self.searchable_fields
      [:localized_string, :string, :localized_paragraph, :paragraph]
    end

    def has_options?
      /option/.match field_type
    end

    def has_localized_value?
      /localized/.match field_type
    end

    def localized_options(locale)
      options.map do |id, translations|
        [translations[locale.to_s], id]
      end
    end

    private

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
