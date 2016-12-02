require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class ConsultationResponseItem
    ATTRIBUTE_NAMES = [
      :id,
      :item_id,
      :item_title,
      :item_budget_line_amount,
      :item_response_options,
      :selected_option_id,
      :selected_option_label,
      :budget_line_amount
    ]

    attr_accessor *ATTRIBUTE_NAMES

    def initialize(attributes = {})
      return unless attributes.is_a?(Hash)

      ATTRIBUTE_NAMES.each do |attribute_name|
        instance_variable_set("@#{attribute_name}", attributes[attribute_name])
      end

      @id ||= generate_id
      @budget_line_amount ||= calculate_budget_line_amount
    end

    def response_options
      item_response_options.map do |option_id, option_label|
        OpenStruct.new(
          id: option_id.to_i,
          label: option_label
        )
      end
    end

    private

    def generate_id
      SecureRandom.uuid
    end

    def calculate_budget_line_amount
      case selected_option_label
      when "reduce"   then item_budget_line_amount.to_f / 1.10
      when "keep"     then item_budget_line_amount.to_f
      when "increase" then item_budget_line_amount.to_f * 1.10
      else item_budget_line_amount.to_f
      end
    end
  end
end
