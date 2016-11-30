require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationDecoratorTest < ActiveSupport::TestCase
    def setup
      super
      @subject = ConsultationDecorator.new(consultation)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def test_estimated_completion_time_in_seconds
      consultation.stub(:consultation_items, []) do
        assert_equal 0, @subject.estimated_completion_time_in_seconds
      end

      assert_equal 90, @subject.estimated_completion_time_in_seconds
    end
  end
end
