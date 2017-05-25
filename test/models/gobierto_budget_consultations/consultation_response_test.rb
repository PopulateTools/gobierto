# frozen_string_literal: true

require 'test_helper'

module GobiertoBudgetConsultations
  class ConsultationResponseTest < ActiveSupport::TestCase
    def consultation_response
      @consultation_response ||= gobierto_budget_consultations_consultation_responses(:dennis_madrid_open)
    end

    def consultation_response_deficit
      @consultation_response_deficit ||= gobierto_budget_consultations_consultation_responses(:reed_madrid_open_deficit)
    end

    def test_valid
      assert consultation_response.valid?
    end

    def test_invalid
      refute consultation_response_deficit.valid?
    end

    def test_consultation_items
      consultation_response.consultation_items.each do |consultation_response_item|
        assert_kind_of ConsultationResponseItem, consultation_response_item
      end
    end
  end
end
