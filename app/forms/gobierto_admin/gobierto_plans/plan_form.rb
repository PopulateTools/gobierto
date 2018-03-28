# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :footer_translations,
        :css,
        :introduction_translations,
        :year,
        :plan_type_id,
        :configuration_data,
        :visibility_level,
        :slug
      )

      validates :site_id, presence: true
      validate :configuration_data_format

      delegate :persisted?, to: :plan

      def save
        save_plan if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def plan
        @plan ||= plan_class.find_by(id: id).presence || build_plan
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def plan_type
        @plan_type ||= ::GobiertoPlans::PlanType.find_by(id: plan_type_id)
      end

      private

      def build_plan
        plan_class.new
      end

      def plan_class
        ::GobiertoPlans::Plan
      end

      def save_plan
        @plan = plan.tap do |plan_attributes|
          plan_attributes.site_id = site_id
          plan_attributes.title_translations = title_translations
          plan_attributes.introduction_translations = introduction_translations
          plan_attributes.css = css
          plan_attributes.configuration_data = configuration_data
          plan_attributes.plan_type_id = plan_type_id
          plan_attributes.visibility_level = visibility_level
          plan_attributes.slug = slug
          plan_attributes.year = year
          plan_attributes.footer_translations = footer_translations
        end

        if @plan.valid?
          @plan.save

          @plan
        else
          promote_errors(@plan.errors)

          false
        end
      end

      def configuration_data_format
        return if configuration_data.blank? || configuration_data.is_a?(Hash)

        JSON.parse(configuration_data)
      rescue JSON::ParserError
        errors.add :configuration_data, I18n.t("errors.messages.invalid")
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
