# frozen_string_literal: true

module GobiertoAdmin
  class ScopeForm < BaseForm

    attr_accessor(
      :id,
      :site_id,
      :name_translations,
      :description_translations,
      :slug
    )

    delegate :persisted?, to: :scope

    # custom validation for json_translate
    validate :name_presence

    def initialize(options = {})
      super(options)
    end

    def save
      save_scope if valid?
    end

    def scope
      @scope ||= scope_class.find_by(id: id).presence || build_scope
    end

    def site_id
      @site_id ||= scope.site_id
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def name
      scope.name
    end

    private

    def build_scope
      scope_class.new
    end

    def scope_class
      ::GobiertoCommon::Scope
    end

    def save_scope
      @scope = scope.tap do |scope_attributes|
        scope_attributes.site_id = site_id
        scope_attributes.name_translations = name_translations
        scope_attributes.description_translations = description_translations
        scope_attributes.slug = slug
      end

      if @scope.valid?
        @scope.save

        @scope
      else
        promote_errors(@scope.errors)

        false
      end
    end

    def name_presence
      if name_translations.values.select { |name| name.present? }.empty?
        errors.add(:name, :blank)
      end
    end

  end
end
