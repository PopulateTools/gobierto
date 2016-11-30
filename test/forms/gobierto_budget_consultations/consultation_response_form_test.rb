require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseFormTest < ActiveSupport::TestCase
    def valid_consultation_response_form
      @valid_consultation_response_form ||= ConsultationResponseForm.new(
        user_id: user.id,
        consultation_id: consultation.id,
        selected_responses: selected_responses_params
      )
    end

    def invalid_consultation_response_form
      @invalid_consultation_response_form ||= ConsultationResponseForm.new(
        user_id: nil,
        consultation_id: nil,
        selected_responses: nil
      )
    end

    def selected_responses_params
      @selected_responses_params ||= {
        consultation_item.id => selected_response_id,
        "wadus" => "2",
        "foo" => "2"
      }
    end

    def selected_response_id
      @selected_response_id ||= consultation_item.available_responses.first[0]
    end

    def selected_response_label
      @selected_response_label ||= consultation_item.available_responses.first[1]
    end

    def user
      @user ||= users(:dennis)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def consultation_item
      @consultation_item ||= gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
    end

    def test_save_with_valid_attributes
      assert valid_consultation_response_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_consultation_response_form.save

      assert_equal 1, invalid_consultation_response_form.errors.messages[:user].size
      assert_equal 1, invalid_consultation_response_form.errors.messages[:consultation].size
      assert_equal 1, invalid_consultation_response_form.errors.messages[:selected_responses].size
    end

    def test_consultation_items
      consultation_response = valid_consultation_response_form.save

      expected_consultation_items = [
        {
          "item_id"                  => consultation_item.id,
          "item_title"               => consultation_item.title,
          "item_budget_line_amount"  => consultation_item.budget_line_amount,
          "item_available_responses" => consultation_item.available_responses,
          "selected_response_id"     => selected_response_id,
          "selected_response_label"  => selected_response_label
        }
      ]

      consultation_items = consultation_response.consultation_items.map do |consultation_item|
        consultation_item.except(*%w(id budget_line_amount))
      end

      assert_equal expected_consultation_items, consultation_items
    end
  end
end
