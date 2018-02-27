# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanTypeForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :name_translations,
        :slug,
        :site_id
      )
      validates :site_id, presence: true

      delegate :persisted?, to: :plan_type

      def site
        @site ||= Site.find_by(id: site_id)
      end

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
          plan_type_attributes.site_id = site_id
          plan_type_attributes.name_translations = name_translations
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
