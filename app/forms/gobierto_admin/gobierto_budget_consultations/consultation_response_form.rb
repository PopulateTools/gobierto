# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationResponseForm < BaseForm

      include ::GobiertoCommon::CustomUserFieldsHelper

      attr_accessor(
        :consultation_id,
        :document_number_digest,
        :selected_options,
        :date_of_birth_year,
        :date_of_birth_month,
        :date_of_birth_day,
        :gender,
        :custom_records_attributes
      )

      delegate :to_model, :persisted?, to: :consultation_response

      validates :document_number_digest, :consultation, :selected_options,
                :site, :census_item, presence: true

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

      def user
        nil
      end

      def date_of_birth
        @date_of_birth ||= if date_of_birth_year && date_of_birth_month && date_of_birth_day
          Date.new(
            date_of_birth_year.to_i,
            date_of_birth_month.to_i,
            date_of_birth_day.to_i
          )
        end
      rescue ArgumentError
        nil
      end

      def custom_records=(attributes)
        @custom_records_attributes ||= Hash[Array(attributes).map do |name, field_attributes|
          custom_user_field = site.custom_user_fields.find(field_attributes["custom_user_field_id"])
          custom_record = custom_user_field.records.new
          custom_record.value = field_attributes["value"]
          [name, { "raw_value" => custom_record.raw_value, "localized_value" => custom_record.value }]
        end]
      end

      private

      # User custom records are not mandatory if the consultation is being created by an admin
      def valid_custom_records
        true
      end

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
          consultation_response_attributes.user_information = {
            gender: gender,
            date_of_birth: date_of_birth.to_s
          }.merge(custom_records_attributes || {})
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

    end
  end
end
