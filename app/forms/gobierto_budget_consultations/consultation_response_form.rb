# frozen_string_literal: true

module GobiertoBudgetConsultations
  class ConsultationResponseForm < BaseForm

    attr_accessor(
      :document_number_digest,
      :consultation_id,
      :selected_options,
      :date_of_birth_year,
      :date_of_birth_month,
      :date_of_birth_day,
      :gender,
      :custom_records_attributes,
      :user
    )

    delegate :to_model, :persisted?, to: :consultation_response

    validates :selected_options, :document_number_digest, :consultation, :user, presence: true

    def save
      save_consultation_response if valid?
    end

    def consultation_response
      @consultation_response ||= build_consultation_response
    end

    def consultation
      @consultation ||= consultation_class.find_by(id: consultation_id)
    end

    def site
      @site ||= consultation.site if consultation
    end

    def budget_amount
      @budget_amount ||= begin
        consultation_response.budget_amount.zero? ? consultation.budget_amount : consultation_response.budget_amount
      end
    end

    private

    def consultation_response_items
      @consultation_response_items ||= begin
        selected_options.map do |_, selected_option_item|
          consultation_item = consultation.consultation_items.find_by(id: selected_option_item["item_id"])
          raise GobiertoBudgetConsultations::ConsultationResponseItem::MissingItem unless consultation_item.present?

          selected_option = selected_option_item["selected_option"]
          raise GobiertoBudgetConsultations::ConsultationResponseItem::EmptySelectedOption if selected_option.blank?

          selected_option = selected_option.to_i

          raise GobiertoBudgetConsultations::ConsultationResponseItem::NotAllowedToReduce if selected_option < 0 && consultation_item.block_reduction?

          consultation_response_item_class.new(
            item_id: consultation_item.id,
            item_title: consultation_item.title,
            item_budget_line_amount: consultation_item.budget_line_amount,
            item_response_options: consultation_item.raw_response_options,
            selected_option: selected_option,
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
        consultation_response_attributes.document_number_digest = document_number_digest
        consultation_response_attributes.consultation_items = consultation_response_items
        consultation_response_attributes.budget_amount = consultation_response_items.sum(&:budget_line_amount)
        consultation_response_attributes.sharing_token ||= consultation_response_class.generate_unique_secure_token
        consultation_response_attributes.visibility_level = consultation_class.visibility_levels[:active]
        consultation_response_attributes.user_information = {
          gender: user.gender,
          date_of_birth: user.date_of_birth.to_s
        }.merge(custom_records_for_user || {}) if user
      end

      if @consultation_response.valid?
        @consultation_response.save

        @consultation_response
      else
        promote_errors(@consultation_response.errors)

        false
      end
    rescue GobiertoBudgetConsultations::ConsultationResponseItem::MissingItem
      Rails.logger.debug "[exception] #{$!}"
      errors[:base] << I18n.t("errors.messages.invalid_consultation_response")
      false
    rescue GobiertoBudgetConsultations::ConsultationResponseItem::EmptySelectedOption
      Rails.logger.debug "[exception] #{$!}"
      errors[:base] << I18n.t("errors.messages.invalid_consultation_response")
      false
    rescue GobiertoBudgetConsultations::ConsultationResponseItem::NotAllowedToReduce
      Rails.logger.debug "[exception] #{$!}"
      errors[:base] << I18n.t("errors.messages.invalid_consultation_response")
      false
    end

    def custom_records_for_user
      @custom_records_for_user ||= Hash[Array(user.custom_records).map do |custom_record|
        [custom_record.custom_user_field.name, { "raw_value" => custom_record.raw_value, "localized_value" => custom_record.value }]
      end]
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
