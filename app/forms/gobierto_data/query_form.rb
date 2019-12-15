# frozen_string_literal: true

module GobiertoData
  class QueryForm < BaseForm

    attr_accessor(
      :id,
      :site_id,
      :dataset_id,
      :user_id,
      :name_translations,
      :sql
    )

    attr_writer(
      :privacy_status
    )

    validates :dataset, :site, :user, :sql, presence: true
    validates :name_translations, translated_attribute_presence: true
    validate :sql_validation

    delegate :persisted?, to: :query

    def query
      @query ||= query_class.find_by(id: id) || build_query
    end

    def dataset
      @dataset ||= site.datasets.find_by(id: dataset_id)
    end

    def user
      @user ||= site.users.find_by(id: user_id)
    end

    def privacy_status
      @privacy_status ||= :open
    end

    def save
      save_query if valid?
    end

    private

    def build_query
      query_class.new
    end

    def query_class
      Query
    end

    def save_query
      @query = query.tap do |attributes|
        attributes.dataset_id = dataset_id
        attributes.user_id = user_id
        attributes.name_translations = name_translations
        attributes.sql = sql
        attributes.privacy_status = privacy_status
      end

      return @query if @query.save

      promote_errors(@query.errors)

      false
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def sql_validation
      return if sql.blank?

      query_test = Connection.execute_query(site, "explain #{sql}", include_stats: false)
      if query_test.has_key? :errors
        errors.add(:sql, query_test[:errors].map { |error| error[:sql] }.join("\n"))
      end
    end
  end
end
