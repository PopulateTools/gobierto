module GobiertoBudgetConsultations
  class ConsultationResponseForm
    include ActiveModel::Model

    attr_accessor(
      :user_id,
      :consultation_id,
      :selected_options
    )

    delegate :to_model, :persisted?, to: :consultation_response

    validates :selected_options, presence: true
    validates :user, :consultation, presence: true

    def save
      save_consultation_response if valid?
    end

    def consultation_response
      @consultation_response ||= find_consultation_response || build_consultation_response
    end

    def consultation
      @consultation ||= consultation_class.find_by(id: consultation_id)
    end

    def user
      @user ||= User.find_by(id: user_id)
    end

    def budget_amount
      @budget_amount ||= begin
        consultation_response.budget_amount.zero? ? consultation.budget_amount : consultation_response.budget_amount
      end
    end

    def selected_option?(consultation_item, response_option)
      return response_option.selected? unless persisted?

      consultation_response.consultation_items.detect do |response_ci|
        response_ci.item_id == consultation_item.id
      end.try(:selected_option_id) == response_option.id
    end

    private

    def consultation_response_items
      # `selected_options` format.
      #
      # The following structure represents a mapping between a
      # `ConsultationItem` id and a response option id:
      #
      # {
      #   "26213347" => "1",
      #   "26213346" => "2",
      #   "26213345" => "2"
      # }
      #
      @consultation_response_items ||= begin
        selected_options.map do |selected_option_pair|
          consultation_item_id, selected_option_id = selected_option_pair.map(&:to_i)

          consultation_item = consultation_items.detect do |item|
            item.id == consultation_item_id
          end

          next unless consultation_item.present?

          response_options = consultation_item.raw_response_options
          selected_option_label = response_options[selected_option_id]

          consultation_response_item_class.new(
            item_id: consultation_item_id,
            item_title: consultation_item.title,
            item_budget_line_amount: consultation_item.budget_line_amount,
            item_response_options: response_options,
            selected_option_id: selected_option_id,
            selected_option_label: selected_option_label
          )
        end.compact
      end
    end

    def find_consultation_response
      consultation.consultation_responses.sorted.find_by(user_id: user_id)
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
        consultation_response_attributes.sharing_token ||= consultation_response_class.generate_unique_secure_token
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
