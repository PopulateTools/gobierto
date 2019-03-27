# frozen_string_literal: true

require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class ConsultationItem < ApplicationRecord
    include GobiertoCommon::Sortable

    RESPONSE_OPTIONS = {
      "-5" => "reduce",
      "0"  => "keep",
      "5"  => "increase"
    }.freeze

    SELECTED_RESPONSE_OPTION_IDS = [1].freeze

    belongs_to :consultation

    validates :title, presence: true

    scope :sorted, -> { order(position: :asc, created_at: :desc) }

    def response_options
      RESPONSE_OPTIONS.map do |option_id, option_label|
        OpenStruct.new(
          id: option_id,
          label: option_label,
          selected?: SELECTED_RESPONSE_OPTION_IDS.include?(option_id)
        )
      end
    end

    def raw_response_options
      RESPONSE_OPTIONS
    end
  end
end
