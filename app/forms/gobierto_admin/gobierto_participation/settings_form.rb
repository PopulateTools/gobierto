# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class SettingsForm < BaseForm

      attr_accessor(
        :issues_vocabulary_id,
        :scopes_vocabulary_id,
        :users_issues_field_id
      )

      attr_writer :site_id

      delegate :persisted?, to: :gobierto_module_settings
      validates :site, presence: true

      def save
        valid? && save_settings
      end

      def gobierto_module_settings
        @gobierto_module_settings ||= gobierto_module_settings_class.find_by(site_id: site_id, module_name: "GobiertoParticipation") || build_gobierto_module_settings
      end

      def site_id
        @site_id ||= gobierto_module_settings.site_id
      end

      def site
        @site ||= Site.find site_id
      end

      def vocabularies_options
        site.vocabularies.map do |vocabulary|
          [vocabulary.name, vocabulary.id]
        end
      end

      def users_issues_fields_options
        site.custom_fields.vocabulary_options.for_class(User).map do |custom_field|
          [custom_field.name, custom_field.id]
        end
      end

      private

      def gobierto_module_settings_class
        ::GobiertoModuleSettings
      end

      def build_gobierto_module_settings
        gobierto_module_settings_class.new
      end

      def save_settings
        @gobierto_module_settings = gobierto_module_settings.tap do |settings_attributes|
          settings_attributes.module_name = "GobiertoParticipation"
          settings_attributes.site_id = site_id
          settings_attributes.issues_vocabulary_id = issues_vocabulary_id
          settings_attributes.scopes_vocabulary_id = scopes_vocabulary_id
          settings_attributes.users_issues_field_id = users_issues_field_id
        end

        if @gobierto_module_settings.save
          true
        else
          promote_errors(@gobierto_module_settings.errors)
          false
        end
      end

      def issues_vocabulary
        @issues_vocabulary ||= site.vocabularies.find_by_id(issues_vocabulary_id)
      end

      def scopes_vocabulary
        @scopes_vocabulary ||= site.vocabularies.find_by_id(scopes_vocabulary_id)
      end

      def users_issues_field
        @users_issues_field ||= site.custom_fields.find_by_id(users_issues_field_id)
      end
    end
  end
end
