require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class ConsultationResponse < ApplicationRecord
    belongs_to :consultation
    belongs_to :user

    serialize :consultation_items, JSON

    enum visibility_level: { draft: 0, active: 1 }

    scope :sorted, -> { order(created_at: :desc) }

    def consultation_items
      @consultation_items ||= Array(read_attribute(:consultation_items)).map do |consultation_response_item_attributes|
        ConsultationResponseItem.new(consultation_response_item_attributes.symbolize_keys)
      end
    end

    def consultation_items=(consultation_response_items)
      @consultation_items = Array(consultation_response_items).map do |consultation_response_item|
        consultation_response_item.instance_values
      end

      write_attribute(:consultation_items, @consultation_items)
    end
  end
end
