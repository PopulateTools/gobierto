require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class ConsultationResponse < ApplicationRecord
    belongs_to :consultation
    belongs_to :user

    serialize :consultation_items, JSON

    enum visibility_level: { draft: 0, active: 1 }

    validates :consultation_id, uniqueness: { scope: :user_id }
    validate :responses_balance

    scope :sorted, -> { order(created_at: :desc) }

    def self.find_by_document_number(document_number, args)
      consultation = args.fetch(:consultation)
      site = args.fetch(:site)

      user = nil
      User::Verification.where(site_id: site.id, verified: true).each do |user_verification|
        if user_verification.verification_data['document_number'] == document_number
          if user = user_verification.user
            if response = consultation.consultation_responses.where(user_id: user.id).first
              return [response, user]
            end
          end
        end
      end
      return [nil, user]
    end

    def consultation_items
      Array(read_attribute(:consultation_items)).map do |consultation_response_item_attributes|
        ConsultationResponseItem.new(consultation_response_item_attributes.symbolize_keys)
      end
    end

    def consultation_items=(consultation_response_items)
      @consultation_items = Array(consultation_response_items).map do |consultation_response_item|
        consultation_response_item.instance_values
      end

      write_attribute(:consultation_items, @consultation_items)
    end

    private

    def responses_balance
      if consultation.force_responses_balance? && deficit_response?
        Rails.logger.debug "[exception] Trying to save deficit response"

        errors[:base] << I18n.t('errors.messages.invalid_consultation_response')
      end
    end

    def deficit_response?
      possitive_items = self.consultation_items.select{ |i| i.selected_option > 0 }
      negative_items =self.consultation_items.select{ |i| i.selected_option < 0 }
      possitive_items.length > negative_items.length
    end
  end
end
