# frozen_string_literal: true

module GobiertoDashboards
  class DashboardForm < BaseForm
    include ::GobiertoCore::TranslationsHelpers
    include ActiveModel::Serialization

    attr_accessor(
      :site_id,
      :admin_id,
      :widgets_configuration,
      :context
    )

    attr_writer(
      :id,
      :title_translations,
      :title,
      :visibility_level
    )

    validate :context_presence
    validates :title, :visibility_level, :site, presence: true
    validates :title_translations, translated_attribute_presence: true
    validates :visibility_level, inclusion: { in: Dashboard.visibility_levels.keys }
    validate :widgets_configuration_json_format

    delegate :persisted?, to: :resource

    def resource
      @resource ||= resource_class.find_by(id: @id) || build_resource
    end
    alias dashboard resource

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def id
      @id ||= resource.id
    end

    def title_translations
      @title_translations ||= (resource.title_translations || available_locales_blank_translations).tap do |translations|
        translations[I18n.locale] = @title if @title.present?
      end
    end

    def title
      title_translations.with_indifferent_access[I18n.locale].presence || title_translations.values.find(&:present?)
    end

    def visibility_level
      @visibility_level ||= resource.visibility_level || :draft
    end

    def context_service
      @context_service ||= GobiertoCommon::ContextService.new(context)
    end

    def save
      save_resource if valid?
    end

    def available_visibility_levels
      Dashboard.visibility_levels
    end

    private

    def widgets_configuration_json_format
      return if widgets_configuration.blank? || widgets_configuration.is_a?(Enumerable)

      @widgets_configuration = JSON.parse(widgets_configuration)
    rescue JSON::ParserError
      errors.add :widgets_configuration, I18n.t("errors.messages.invalid")
    end

    def transformed_widgets_configuration
      return if widgets_configuration.blank?

      widgets_configuration_json_format if widgets_configuration.is_a?(String)

      @widgets_configuration.map do |widget_configuration|
        widget_configuration.merge(widget_configuration.slice("x", "y", "w", "h").transform_values(&:to_i))
      end
    end

    def context_presence
      errors.add(:context, I18n.t("errors.messages.not_found")) unless context_service.present?
    end

    def build_resource
      resource_class.new
    end

    def resource_class
      Dashboard
    end

    def save_resource
      @resource = resource.tap do |attributes|
        attributes.site_id = site.id
        attributes.title_translations = title_translations
        attributes.context = context_service.context
        attributes.visibility_level = visibility_level
        attributes.widgets_configuration = transformed_widgets_configuration
      end

      if @resource.save
        @resource
      else
        promote_errors(@resource.errors)
        false
      end
    end
  end
end
