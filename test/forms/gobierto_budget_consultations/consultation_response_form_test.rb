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
        selected_options: nil
      )
    end

    def selected_options_params
      @selected_options_params ||= {
        consultation_item.id => selected_option.id,
        "wadus" => "2",
        "foo" => "2"
      }
    end

    def selected_option
      @selected_option ||= consultation_item.response_options.first
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
      assert_equal 1, invalid_consultation_response_form.errors.messages[:selected_options].size
    end

    def test_consultation_response_items
      consultation_response = valid_consultation_response_form.save

      expected_consultation_items = [
        {
          "item_id"                 => consultation_item.id,
          "item_title"              => consultation_item.title,
          "item_budget_line_amount" => consultation_item.budget_line_amount,
          "item_response_options"   => consultation_item.raw_response_options,
          "selected_option_id"      => selected_option.id,
          "selected_option_label"   => selected_option.label
        }
      ]

      consultation_items = consultation_response.consultation_items.map do |consultation_item|
        consultation_item.except(*%w(id budget_line_amount))
      end

      assert_equal expected_consultation_items, consultation_items
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
