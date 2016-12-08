require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationItemFormTest < ActiveSupport::TestCase
      def valid_consultation_item_form
        @valid_consultation_item_form ||= ConsultationItemForm.new(
          consultation_id: consultation.id,
          title: consultation_item.title,
          description: consultation_item.description,
          budget_line_id: "Wadus",
          budget_line_amount: 10.0
        )
      end

      def valid_persisted_consultation_item_form
        @valid_persisted_consultation_item_form ||= ConsultationItemForm.new(
          consultation_id: consultation.id,
          title: consultation_item.title,
          description: consultation_item.description,
          position: consultation_item.position,
          budget_line_id: "Wadus",
          budget_line_amount: 10.0
        )
      end

      def invalid_consultation_item_form
        @invalid_consultation_item_form ||= ConsultationItemForm.new(
          consultation_id: consultation.id,
          title: nil,
          description: nil,
          budget_line_id: nil,
          budget_line_amount: nil
        )
      end

      def consultation_item
        @consultation_item ||= gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
      end

      def latest_consultation_item
        @latest_consultation_item ||= gobierto_budget_consultations_consultation_items(:madrid_civil_protection)
      end

      def consultation
        @consultation ||= consultation_item.consultation
      end

      def test_save_with_valid_attributes
        assert valid_consultation_item_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_consultation_item_form.save

        assert_equal 1, invalid_consultation_item_form.errors.messages[:title].size
        assert_equal 1, invalid_consultation_item_form.errors.messages[:budget_line_id].size
        assert_equal 1, invalid_consultation_item_form.errors.messages[:budget_line_amount].size
      end

      def test_calculate_consultation_budget_amount
        assert_difference "consultation.reload.budget_amount", 10.0 do
          valid_consultation_item_form.save
        end
      end

      def test_position
        assert_equal latest_consultation_item.position + 1,
          valid_consultation_item_form.position

        assert_equal consultation_item.position,
          valid_persisted_consultation_item_form.position
      end
    end
  end
end
