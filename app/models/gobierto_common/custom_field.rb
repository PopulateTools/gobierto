# frozen_string_literal: true

module GobiertoCommon
  class CustomField < ApplicationRecord
    belongs_to :site
    has_many :records, dependent: :destroy, class_name: "CustomFieldRecord"

    enum field_type: { string: 0,
                       localized_string: 1,
                       paragraph: 2,
                       localized_paragraph: 3,
                       single_option: 4,
                       multiple_options: 5 }

    scope :sorted, -> { order(position: :asc) }

    translates :name

    before_create :set_uid, :set_position

    private

    def set_uid
      self.uid ||= SecureRandom.uuid
    end

    def set_position
      self.position = begin
        self.class.where(site_id: site_id).maximum(:position).to_i + 1
      end
    end
  end
end
