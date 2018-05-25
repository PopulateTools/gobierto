# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationItemForm < BaseForm

      attr_accessor(
        :id,
        :consultation_id,
        :title,
        :description,
        :position,
        :budget_line_id,
        :budget_line_name,
        :budget_line_amount,
        :block_reduction
      )

      attr_reader :consultation_item

      delegate :persisted?, to: :consultation_item

      validates :title, presence: true
      validates :budget_line_amount, presence: true
      validates :consultation, presence: true

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          save_consultation_item
          consultation.calculate_budget_amount
        end
      end

      def consultation_item
        @consultation_item ||= consultation_item_class.find_by(id: id).presence || build_consultation_item
      end

      def consultation_id
        @consultation_id ||= consultation_item.consultation_id
      end

      def consultation
        @consultation ||= consultation_class.includes(:consultation_items).find(consultation_id)
      end

      def position
        @position ||= begin
          consultation_item.position.zero? ? next_consultation_item_position : consultation_item.position
        end
      end

      private

      def build_consultation_item
        consultation_item_class.new
      end

      def consultation_item_class
        ::GobiertoBudgetConsultations::ConsultationItem
      end

      def consultation_class
        ::GobiertoBudgetConsultations::Consultation
      end

      def save_consultation_item
        @consultation_item = consultation_item.tap do |consultation_item_attributes|
          consultation_item_attributes.consultation_id = consultation_id
          consultation_item_attributes.title = title
          consultation_item_attributes.description = description
          consultation_item_attributes.budget_line_id = budget_line_id
          consultation_item_attributes.budget_line_name = budget_line_name
          consultation_item_attributes.budget_line_amount = budget_line_amount.to_f
          consultation_item_attributes.position = position
          consultation_item_attributes.block_reduction = block_reduction
        end

        if @consultation_item.valid?
          @consultation_item.save

          @consultation_item
        else
          promote_errors(@consultation_item.errors)

          false
        end
      end

      protected

      def next_consultation_item_position
        consultation.consultation_items.map(&:position).max.to_i + 1
      end

    end
  end
end
