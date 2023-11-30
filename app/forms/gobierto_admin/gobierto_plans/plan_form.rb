# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanForm < BaseForm

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :footer_translations,
        :css,
        :introduction_translations,
        :year,
        :plan_type_id,
        :slug,
        :categories_vocabulary,
        :statuses_vocabulary
      )

      attr_writer(
        :configuration_data,
        :visibility_level,
        :vocabulary_id,
        :statuses_vocabulary_id,
        :publish_last_version_automatically
      )

      validates :site_id, :configuration_data, presence: true
      validates :vocabulary_id, presence: true, if: :persisted?
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

      def vocabulary_id
        @vocabulary_id ||= identify_vocabulary(categories_vocabulary) || plan.vocabulary_id
      end

      def configuration_data
        @configuration_data ||= plan.new_record? ? ::GobiertoPlans.default_plans_configuration_data : plan.configuration_data
      end

      def statuses_vocabulary_id
        @statuses_vocabulary_id ||= identify_vocabulary(statuses_vocabulary) || plan.statuses_vocabulary_id
      end

      def publish_last_version_automatically
        @publish_last_version_automatically ||= plan.publish_last_version_automatically? || false
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
          plan_attributes.vocabulary_id = vocabulary_id
          plan_attributes.statuses_vocabulary_id = statuses_vocabulary_id
          plan_attributes.publish_last_version_automatically = publish_last_version_automatically
        end

        if @plan.valid?
          @plan.save

          @plan
        else
          promote_errors(@plan.errors)

          false
        end
      end

      def identify_vocabulary(id_or_slug)
        return if id_or_slug.blank?

        is_number = id_or_slug.is_a?(Integer) || /\A\d+\z/.match?(id_or_slug.to_s.strip)

        vocabulary = is_number && site.vocabularies.find_by_id(id_or_slug.to_s.strip) || site.vocabularies.find_by_slug(id_or_slug.to_s)
        vocabulary&.id
      end

      def configuration_data_format
        return if configuration_data.blank? || configuration_data.is_a?(Hash)

        JSON.parse(configuration_data)
      rescue JSON::ParserError
        errors.add :configuration_data, I18n.t("errors.messages.invalid")
      end

    end
  end
end
