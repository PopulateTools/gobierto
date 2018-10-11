# frozen_string_literal: true

module GobiertoCommon
  class CustomField < ApplicationRecord
    belongs_to :site
    has_many :records, dependent: :destroy, class_name: "CustomFieldRecord"
    validates :name, presence: true

    enum field_type: { localized_string: 0,
                       string: 1,
                       localized_paragraph: 2,
                       paragraph: 3,
                       single_option: 4,
                       multiple_options: 5 }

    scope :sorted, -> { order(position: :asc) }

    translates :name

    before_create :set_uid, :set_position

    def self.field_types_with_options
      field_types.select { |key, _| /option/.match(key) }
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
      return if uid.present?

      self.uid = SecureRandom.uuid
    end

    def set_position
      self.position = begin
        self.class.where(site_id: site_id).maximum(:position).to_i + 1
      end
    end
  end
end
