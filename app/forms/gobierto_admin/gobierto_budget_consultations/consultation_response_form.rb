module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationResponseForm
      include ActiveModel::Model

      attr_accessor(
        :consultation_id,
        :document_number_digest,
        :selected_options
      )

      delegate :to_model, :persisted?, to: :consultation_response

      validates :document_number_digest, :consultation, :selected_options, :site, :census_item, presence: true

      def save
        save_consultation_response if valid?
      end

      def consultation_response
        @consultation_response ||= build_consultation_response
      end

      def consultation
        @consultation ||= consultation_class.find_by(id: consultation_id)
      end

      def census_item
        @census_item ||= if site
          CensusItem.find_by(site_id: site.id, document_number_digest: document_number_digest)
        end
      end

      def selected_options
        @selected_options || build_selected_options
      end

      def site
        @site ||= consultation.site if consultation
      end

      private

      def consultation_class
        ::GobiertoBudgetConsultations::Consultation
      end

      def build_selected_options
        Hash[consultation.consultation_items.map do |consultation_item|
          [consultation_item.id.to_s, nil]
        end]
      end

      def build_consultation_response
        consultation_response_class.new
      end

      def consultation_items
        @consultation_items ||= begin
          selected_options.map do |item_id, selected_option|
            consultation_item = consultation.consultation_items.find_by(id: item_id)

            consultation_response_item_class.new(
              item_id: consultation_item.id,
              item_title: consultation_item.title,
              item_budget_line_amount: consultation_item.budget_line_amount,
              item_response_options: consultation_item.raw_response_options,
              selected_option: selected_option.to_i,
            )
          end.compact
        end
      end

      def save_consultation_response
        @consultation_response = consultation_response.tap do |consultation_response_attributes|
          consultation_response_attributes.consultation_id = consultation_id
          consultation_response_attributes.document_number_digest = document_number_digest
          consultation_response_attributes.consultation_items = consultation_items
          consultation_response_attributes.budget_amount = consultation_items.sum(&:budget_line_amount)
          consultation_response_attributes.sharing_token ||= consultation_response_class.generate_unique_secure_token
          consultation_response_attributes.visibility_level = consultation_class.visibility_levels[:active]
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

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
