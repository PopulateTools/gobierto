# frozen_string_literal: true

require_dependency "gobierto_budget_consultations"
require_dependency "secret_attribute"

module GobiertoBudgetConsultations
  class ConsultationResponse < ApplicationRecord
    belongs_to :consultation

    serialize :consultation_items, JSON

    enum visibility_level: { draft: 0, active: 1 }

    validates :document_number_digest, presence: true
    validates :consultation_id, uniqueness: { scope: :document_number_digest }
    validate :responses_balance

    scope :sorted, -> { order(created_at: :desc) }

    def self.find_by_document_number(document_number)
      find_by(document_number_digest: ::SecretAttribute.digest(document_number))
    end

    def consultation_items
      Array(read_attribute(:consultation_items)).map do |consultation_response_item_attributes|
        ConsultationResponseItem.new(consultation_response_item_attributes.symbolize_keys)
      end
    end

    def consultation_items=(consultation_response_items)
      @consultation_items = Array(consultation_response_items).map do |consultation_response_item|
        consultation_response_item.instance_values
      end

      write_attribute(:consultation_items, @consultation_items)
    end

    private

    def responses_balance
      if consultation.force_responses_balance? && deficit_response?
        Rails.logger.debug "[exception] Trying to save deficit response"

        errors[:base] << I18n.t("errors.messages.invalid_consultation_response")
      end
    end

    def deficit_response?
      possitive_items = consultation_items.select { |i| i.selected_option > 0 }
      negative_items  = consultation_items.select { |i| i.selected_option < 0 }
      possitive_items.length > negative_items.length
    end
  end
end
