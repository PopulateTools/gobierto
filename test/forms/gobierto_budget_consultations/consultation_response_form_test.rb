require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseFormTest < ActiveSupport::TestCase
    def valid_consultation_response_form
      @valid_consultation_response_form ||= ConsultationResponseForm.new(
        user_id: user.id,
        consultation_id: consultation.id,
        selected_options: selected_options_params
      )
    end

    def invalid_consultation_response_form
      @invalid_consultation_response_form ||= ConsultationResponseForm.new(
        user_id: nil,
        consultation_id: nil,
        selected_options: {}
      )
    end

    def selected_options_params
      @selected_options_params ||= {
        '0' => {
          'item_id' => consultation_item_1.id,
          'selected_option' => -5
        },
        '1' => {
          'item_id' => consultation_item_2.id,
          'selected_option' => 0
        }
      }
    end

    def selected_option
      @selected_option ||= consultation_item.response_options.first
    end

    def user
      @user ||= users(:susan)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def consultation_item_1
      @consultation_item_1 ||= gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
    end

    def consultation_item_2
      @consultation_item_2 ||= gobierto_budget_consultations_consultation_items(:madrid_civil_protection)
    end

    def test_save_with_valid_attributes
      assert valid_consultation_response_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_consultation_response_form.save

      assert_equal 1, invalid_consultation_response_form.errors.messages[:user].size
      assert_equal 1, invalid_consultation_response_form.errors.messages[:consultation].size
      assert_equal 1, invalid_consultation_response_form.errors.messages[:selected_options].size
    end

    def test_consultation_response_items
      consultation_response = valid_consultation_response_form.save

      expected_consultation_items = [
        {
          "item_id"                 => consultation_item_1.id,
          "item_title"              => consultation_item_1.title,
          "item_budget_line_amount" => consultation_item_1.budget_line_amount.to_s,
          "selected_option"         => -5
        },
        {
          "item_id"                 => consultation_item_2.id,
          "item_title"              => consultation_item_2.title,
          "item_budget_line_amount" => consultation_item_2.budget_line_amount.to_s,
          "selected_option"         => 0
        }
      ]

      first_item = consultation_response.consultation_items.first
      expected_consultation_items.first.each do |key, value|
        assert_equal first_item.send(key), value
      end

      second_item = consultation_response.consultation_items.second
      expected_consultation_items.second.each do |key, value|
        assert_equal second_item.send(key), value
      end
    end

    def test_budget_amount
      valid_consultation_response_form.consultation_response.stub(:budget_amount, 0.0) do
        assert_equal consultation.budget_amount, valid_consultation_response_form.budget_amount
      end

      valid_consultation_response_form.consultation_response.stub(:budget_amount, 50.0) do
        assert_equal 50.0, valid_consultation_response_form.budget_amount
      end
    end

    def test_sharing_token_generation
      consultation_response = valid_consultation_response_form.save

      assert_not_nil consultation_response.sharing_token
    end

    def test_sharing_token_does_not_change_on_update
      sharing_token = valid_consultation_response_form.save.sharing_token
      consultation_response = valid_consultation_response_form.save

      assert_equal sharing_token, consultation_response.sharing_token
    end
  end
end
