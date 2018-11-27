# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class CharterForm < GobiertoCitizensCharters::BaseForm
      attr_accessor(
        :service_id,
        :title_translations,
        :slug
      )

      validates :service, presence: true
      validates :title_translations, translated_attribute_presence: true

      trackable_on :resource
      notify_changed :visibility_level, :title_translations
      notify_changed :title_translations, as: :charter_attribute
      use_publisher Publishers::AdminGobiertoCitizensChartersActivity

      def available_services
        services_relation.order(Arel.sql("title_translations->'#{I18n.locale}' ASC"))
      end

      def attributes_assignments
        {
          service_id: service.id,
          title_translations: title_translations,
          slug: slug
        }
      end

      private

      def resources_relation
        ::GobiertoCitizensCharters::Charter
      end

      def service
        services_relation.find_by(id: service_id)
      end

      def services_relation
        site.services
      end
    end
  end
end
