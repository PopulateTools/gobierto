# frozen_string_literal: true

module GobiertoPlans
  class Node < ApplicationRecord
    include GobiertoCommon::Moderable
    include GobiertoCommon::HasVocabulary
    include GobiertoCommon::HasPermissionsGroup
    include GobiertoCommon::HasCustomFieldRecords
    include GobiertoCommon::HasExternalId
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable

    multisearchable(
      against: [:versioned_searchable_name, :versioned_searchable_custom_fields],
      additional_attributes: lambda { |item|
        {
          site_id: item.plan.site_id,
          title_translations: item.truncated_translations(:versioned_name),
          resource_path: item.resource_path,
          searchable_updated_at: item.updated_at
        }
      },
      if: :searchable?
    )

    attr_accessor :minor_change

    attr_writer :plan

    belongs_to :author, class_name: "GobiertoAdmin::Admin", foreign_key: :admin_id, optional: true
    has_and_belongs_to_many :categories, class_name: "GobiertoCommon::Term", association_foreign_key: :category_id, join_table: :gplan_categories_nodes

    VERSIONED_ATTRIBUTES = %w(name_translations status_id progress starts_at ends_at options).freeze

    has_paper_trail skip: [:visibility_level, :published_version, :external_id], unless: ->(this) { this.minor_change }
    has_vocabulary :statuses, optional: true
    belongs_to :status, class_name: "GobiertoCommon::Term", optional: true

    delegate :name, to: :status, prefix: true, allow_nil: true

    after_update :check_published_version

    scope :with_name, ->(name) { where("gplan_nodes.name_translations ->> 'en' ILIKE :name OR gplan_nodes.name_translations ->> 'es' ILIKE :name OR gplan_nodes.name_translations ->> 'ca' ILIKE :name", name: "%#{name}%") }
    scope :with_status, ->(status) { where(status_id: status) }
    scope :with_category, ->(category) { where(gplan_categories_nodes: { category_id: GobiertoCommon::Term.find(category).last_descendants }) }
    scope :with_progress, ->(progress) { where("progress > ? AND progress <= ?", *progress.split(" - ")) }
    scope :with_interval, lambda { |interval|
      dates = interval.split(",").map do |date|
        begin
          Date.parse(date)
        rescue ArgumentError
          nil
        end
      end

      dates = [nil, nil].zip(dates).map { |date| date.compact.first }

      where("starts_at >= ? OR ends_at <= ?", *dates)
    }
    scope :with_start_date, ->(start_date) { where("starts_at >= ?", Date.parse(start_date)) }
    scope :with_end_date, ->(end_date) { where("ends_at <= ?", Date.parse(end_date)) }
    scope :with_author, ->(author_id) { where(admin_id: author_id) }
    scope :order_by_assigned_to, lambda { |admin|
      return all if admin.managing_user?

      admin_id = connection.quote(admin.id)
      order(
        Arel.sql("CASE
          WHEN gplan_nodes.admin_id = #{admin_id} THEN 0
          WHEN EXISTS (
            SELECT 1 FROM admin_admin_groups
            INNER JOIN admin_groups_admins ON admin_admin_groups.id = admin_groups_admins.admin_group_id
            WHERE admin_admin_groups.resource_type = 'GobiertoPlans::Node'
            AND admin_admin_groups.resource_id = gplan_nodes.id
            AND admin_groups_admins.admin_id = #{admin_id}
          ) THEN 0
          ELSE 1
        END")
      )
    }
    scope :with_visibility_level, lambda { |visibility_level|
      case visibility_level.to_s
      when "published_up_to_date"
        published.where(
          "(SELECT COUNT(1) FROM versions
            WHERE versions.item_type = 'GobiertoPlans::Node'
            AND versions.item_id = gplan_nodes.id) = 0
           OR
           (gplan_nodes.published_version IS NOT NULL AND
            gplan_nodes.published_version = (
              SELECT COUNT(1) FROM versions
              WHERE versions.item_type = 'GobiertoPlans::Node'
              AND versions.item_id = gplan_nodes.id
            ))"
        )
      when "published_with_unpublished_changes"
        published.where(
          "(SELECT COUNT(1) FROM versions
            WHERE versions.item_type = 'GobiertoPlans::Node'
            AND versions.item_id = gplan_nodes.id) > 0
           AND
           (gplan_nodes.published_version IS NULL OR
            gplan_nodes.published_version != (
              SELECT COUNT(1) FROM versions
              WHERE versions.item_type = 'GobiertoPlans::Node'
              AND versions.item_id = gplan_nodes.id
            ))"
        )
      else
        where(visibility_level:)
      end
    }
    scope :with_admin_actions, lambda { |admin|
      admin_id, action_name, site_id = admin.to_s.split("-")
      admin = GobiertoAdmin::Admin.find(admin_id)
      site = site_id.present? ? Site.find_by(id: site_id) : take&.plan&.site
      if site.present? && action_name.present? && GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(current_admin: admin, current_site: site, project: reorder(nil)).allowed_actions.include?(action_name.to_sym)
        all
      else
        where(author: admin)
      end
    }
    scope :versions_indexes, lambda {
      joins(:versions).
      group("gplan_nodes.id", "gplan_nodes.published_version").
      count("versions.id").reject { |k, v| k.last.blank? }.inject({}) do |counts, (k, v)|
        counts.update(k[0] => k[1] - v)
      end
    }

    default_moderation_stage do |node|
      node.published? ? :approved : :unsent
    end

    translates :name

    enum visibility_level: { draft: 0, published: 1 }

    alias owner author

    def self.node_custom_fields(plan, node)
      if plan.instance_level_custom_fields.any?
        plan.instance_level_custom_fields
      else
        plan.site.custom_fields.sorted.where(class_name: node.class.name, instance: nil)
      end
    end

    def self.node_custom_field_records(plan, node)
      if plan.instance_level_custom_fields.any?
        ::GobiertoCommon::CustomFieldRecord.where(custom_field: plan.instance_level_custom_fields, item: node).sorted
      else
        node.global_custom_field_records
      end
    end

    def self.front_node_custom_field_records(plan, node)
      node_custom_field_records(plan, node).where.not(custom_fields: { uid: plan.configuration_data&.fetch("fields_to_not_show_in_front", []) })
    end

    def global_custom_field_records
      ::GobiertoCommon::CustomFieldRecord.where(item: self).sorted
    end

    def plan
      @plan ||= categories_vocabulary && GobiertoPlans::Plan.find_by(categories_vocabulary: categories_vocabulary)
    end

    def categories_vocabulary
      @categories_vocabulary ||= categories.take&.vocabulary
    end

    def searchable?
      published? && plan.present?
    end

    def versioned_searchable_name
      serialized_version.dig(:searchable_name)
    end

    def versioned_name_translations
      serialized_version.dig(:name_translations)
    end

    def versioned_searchable_custom_fields
      serialized_version.dig(:searchable_custom_fields)
    end

    def parameterize
      params = { id: id, year: plan.year, slug: plan.plan_type.slug }
    end

    def singular_route_key
      :gobierto_plans_project
    end

    def reset_serialized_version
      @serialized_version = nil
    end

    def serialized_version
      @serialized_version ||= GobiertoPlans::NodeSerializer.new(
        self,
        plan: plan,
        serialize_for_search_engine: true,
        custom_fields: plan.front_available_custom_fields.where(field_type: GobiertoCommon::CustomField.searchable_fields)
      ).to_h.symbolize_keys
    end

    def check_published_version
      return unless published?
      return if published_version.nil?

      version_index = published_version - versions.length
      return if published_version > 0 && (version_index >= 0 || version_index < 0 && versions[version_index]&.reify.present?)

      update_columns(published_version: nil, visibility_level: 0)
    end

    def versions_visibility_level
      if published?
        return "published_up_to_date" if versions.none? || versions.count == published_version

        "published_with_unpublished_changes"
      else
        visibility_level
      end
    end
  end
end
