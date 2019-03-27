# frozen_string_literal: true

module GobiertoCommon
  class CustomUserField < ApplicationRecord
    belongs_to :site
    has_many :records, dependent: :destroy, class_name: "CustomUserFieldRecord"

    enum field_type: { string: 0, paragraph: 1, single_option: 2, multiple_options: 3 }

    scope :sorted, -> { order(position: :asc) }

    before_create :set_name, :set_position

    def localized_title
      title[I18n.locale.to_s]
    end

    private

    def set_name
      self.name ||= SecureRandom.uuid
    end

    def set_position
      self.position = begin
        self.class.where(site_id: site_id).maximum(:position).to_i + 1
      end
    end
  end
end
