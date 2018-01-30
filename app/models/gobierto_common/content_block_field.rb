module GobiertoCommon
  class ContentBlockField < ApplicationRecord
    belongs_to :content_block

    attr_accessor :available_locales

    before_create :set_name, :set_position

    serialize :label, Hash

    scope :sorted, -> { order(position: :asc) }

    enum field_type: { text: 0, date: 1, currency: 2, url: 3 }

    def label_components
      available_locales.map do |locale|
        OpenStruct.new(
          attribute_name: "label",
          locale: locale.to_s,
          value: label[locale.to_s]
        )
      end
    end

    def label_components_attributes=(attributes)
      self.label = Array(attributes).reduce({}) do |label_components, (_, field_attributes)|
        label_components.merge!({ field_attributes["locale"] => field_attributes["value"] })
      end
    end

    def localized_label
      label[I18n.locale.to_s]
    end

    private

    def set_name
      self.name = SecureRandom.uuid if self.name.blank?
    end

    def set_position
      self.position = begin
        self.class.where(content_block_id: content_block_id).maximum(:position).to_i + 1
      end
    end
  end
end
