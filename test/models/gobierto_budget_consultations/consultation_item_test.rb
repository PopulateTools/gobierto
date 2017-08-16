# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_common/sortable_test"

module GobiertoBudgetConsultations
  class ConsultationItemTest < ActiveSupport::TestCase
    include GobiertoCommon::SortableTest

    def consultation_item
      @consultation_item ||= gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
    end
    alias sortable_object consultation_item

    def response_option
      @response_option ||= consultation_item.response_options[0]
    end

    def subject_class
      ConsultationItem
    end

    def test_valid
      assert consultation_item.valid?
    end

    def test_response_options
      assert_kind_of Array, consultation_item.response_options
    end

    def test_single_response_option
      assert 0, response_option.id
      assert "reduce", response_option.label
    end

    def test_raw_response_options
      assert ConsultationItem::RESPONSE_OPTIONS, response_option.raw_response_options
    end
  end
end
