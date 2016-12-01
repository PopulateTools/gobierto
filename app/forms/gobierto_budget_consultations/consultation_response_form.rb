module GobiertoBudgetConsultations
  class ConsultationResponseForm
    include ActiveModel::Model

    attr_accessor(
      :user_id,
      :consultation_id,
      :selected_responses
    )

    delegate :to_model, :persisted?, to: :consultation_response

    validates :selected_responses, presence: true
    validates :user, :consultation, presence: true

    def save
      save_consultation_response if valid?
    end

    def consultation_response
      @consultation_response ||= build_consultation_response
    end

    def consultation
      @consultation ||= consultation_class.find_by(id: consultation_id)
    end

    def user
      @user ||= User.find_by(id: user_id)
    end

    private

    def consultation_response_items
      # `selected_responses` format.
      #
      # The following structure represents a mapping between a
      # `ConsultationItem` id and a selected response:
      #
      # {
      #   "26213347" => "1",
      #   "26213346" => "2",
      #   "26213345" => "2"
      # }
      #
      @consultation_response_items ||= begin
        selected_responses.map do |selected_response|
          consultation_item_id = selected_response[0].to_i
          selected_response_id = selected_response[1].to_i

          consultation_item = consultation_items.detect do |item|
            item.id == consultation_item_id
          end

          next unless consultation_item.present?

          available_responses = consultation_item.available_responses
          selected_response_label = available_responses[selected_response_id]

          consultation_response_item_class.new(
            item_id: consultation_item_id,
            item_title: consultation_item.title,
            item_budget_line_amount: consultation_item.budget_line_amount,
            item_available_responses: available_responses,
            selected_response_id: selected_response_id,
            selected_response_label: selected_response_label
          )
        end.compact
      end
    end

    def build_consultation_response
      consultation_response_class.new
    end

    def consultation_class
      ::GobiertoBudgetConsultations::Consultation
    end

    def save_consultation_response
      @consultation_response = consultation_response.tap do |consultation_response_attributes|
        consultation_response_attributes.consultation_id = consultation_id
        consultation_response_attributes.user_id = user_id
        consultation_response_attributes.consultation_items = consultation_response_items
        consultation_response_attributes.budget_amount = consultation_response_items.sum(&:budget_line_amount)
      end

      if @consultation_response.valid?
        @consultation_response.save

        @consultation_response
      else
        promote_errors(@consultation_response.errors)

        false
      end
    end

    protected

    def consultation_response_class
      ::GobiertoBudgetConsultations::ConsultationResponse
    end

    def consultation_response_item_class
      ::GobiertoBudgetConsultations::ConsultationResponseItem
    end

    def consultation_items
      @consultation_items ||= begin
         consultation
           .consultation_items
           .select(:id, :title, :budget_line_amount)
      end
    end

    def promote_errors(errors_hash)
      errors_hash.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
