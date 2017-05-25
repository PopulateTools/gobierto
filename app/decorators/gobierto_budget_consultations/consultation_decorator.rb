# frozen_string_literal: true

module GobiertoBudgetConsultations
  class ConsultationDecorator < BaseDecorator
    CONSULTATION_ITEM_COMPLETION_TIME_IN_SECONDS = 90

    def initialize(consultation)
      @object = consultation
    end

    def estimated_completion_time_in_seconds
      CONSULTATION_ITEM_COMPLETION_TIME_IN_SECONDS * object.consultation_items.count
    end
  end
end
