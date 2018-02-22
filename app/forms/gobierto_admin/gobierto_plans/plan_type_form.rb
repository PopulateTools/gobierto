# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanTypeForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :name,
        :slug
      )

      delegate :persisted?, to: :plan_type

      def save
        save_plan_type if valid?
      end

      def plan_type
        @plan_type ||= plan_type_class.find_by(id: id).presence || build_plan_type
      end

      private

      def build_plan_type
        plan_type_class.new
      end

      def plan_type_class
        ::GobiertoPlans::PlanType
      end

      def save_plan_type
        @plan_type = plan_type.tap do |plan_type_attributes|
          plan_type_attributes.name = name
          plan_type_attributes.slug = slug
        end

        if @plan_type.valid?
          @plan_type.save

          @plan_type
        else
          promote_errors(@plan_type.errors)

          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
