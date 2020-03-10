# frozen_string_literal: true

module GobiertoData
  class VisualizationForm < BaseForm
    include ::GobiertoCore::TranslationsHelpers
    include HasSqlAttribute

    attr_accessor(
      :id,
      :site_id,
      :query_id,
      :dataset_id,
      :user_id,
      :name
    )

    attr_writer(
      :privacy_status,
      :name_translations,
      :spec
    )

    validates :site, :user, :spec, :dataset, presence: true
    validates :name_translations, translated_attribute_presence: true
    validate :spec_validation

    delegate :persisted?, to: :visualization

    def visualization
      @visualization ||= visualization_class.find_by(id: id) || build_visualization
    end

    def query
      @query ||= site.presence && site.queries.find_by(id: query_id) || visualization.query
    end

    def dataset
      @dataset ||= query.present? ? query.dataset : site.presence && site.datasets.find_by(id: dataset_id) || visualization.dataset
    end

    def user
      @user ||= site.presence && site.users.find_by(id: user_id) || visualization.user
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def name_translations
      @name_translations ||= begin
                               (visualization.name_translations || available_locales_blank_translations).tap do |translations|
                                 translations[I18n.locale] = name if name.present?
                               end
                             end
    end

    def privacy_status
      @privacy_status ||= :open
    end

    def spec
      @spec ||= {}
    end

    def save
      save_visualization if valid?
    end

    private

    def build_visualization
      visualization_class.new
    end

    def visualization_class
      Visualization
    end

    def save_visualization
      @visualization = visualization.tap do |attributes|
        attributes.dataset_id = dataset.id
        attributes.query_id = query&.id
        attributes.sql = sql
        attributes.user_id = user.id
        attributes.name_translations = name_translations
        attributes.privacy_status = privacy_status
        attributes.spec = spec
      end

      return @visualization if @visualization.save

      promote_errors(@visualization.errors)

      false
    end

    def spec_validation
      return if spec.blank?
    end
  end
end
