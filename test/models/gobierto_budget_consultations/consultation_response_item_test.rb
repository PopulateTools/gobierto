require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseItemTest < ActiveSupport::TestCase
    def consultation_response_item
      @consultation_response_item ||= begin
        ConsultationResponseItem.new(consultation_response_item_params)
      end
    end

    def test_not_whitelisted_attributes
      assert_raises(NoMethodError) do
        consultation_response_item.wadus
      end
    end

    def test_id_accessor
      assert_not_nil consultation_response_item.id
    end

    def test_budget_line_amount_accessor
      assert_not_nil consultation_response_item.budget_line_amount
    end

    def test_budget_line_amount_on_increase_operation
      consultation_response_item_params[:selected_option] = 5
      assert_equal 10.5, consultation_response_item.budget_line_amount
    end

    def test_budget_line_amount_on_reduce_operation
      consultation_response_item_params[:selected_option] = -5
      assert_equal 9.5, consultation_response_item.budget_line_amount
    end

    def test_budget_line_amount_on_keep_operation
      consultation_response_item_params[:selected_option] = 0
      assert_equal 10.0, consultation_response_item.budget_line_amount
    end

    private

    def consultation_response_item_params
      @consultation_response_item_params ||= begin
        {
          item_id: 26213347,
          item_title: "Pavimentación de vías públicas",
          item_budget_line_amount: "10.0",
          item_response_options: {"0"=>"reduce", "1"=>"keep", "2"=>"increase"},
        }
      end
    end
  end
end
