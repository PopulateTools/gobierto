# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Node < ApplicationRecord
    include GobiertoCommon::Moderable

    has_and_belongs_to_many :categories, class_name: "GobiertoCommon::Term", association_foreign_key: :category_id, join_table: :gplan_categories_nodes
    has_paper_trail ignore: [:visibility_level]

    scope :with_name, ->(name) { where("gplan_nodes.name_translations ->> 'en' LIKE :name OR gplan_nodes.name_translations ->> 'es' LIKE :name OR gplan_nodes.name_translations ->> 'ca' LIKE :name", name: "%#{name}%") }
    scope :with_status, ->(status) { with_status_translation(status) }
    scope :with_category, ->(category) { where(gplan_categories_nodes: { category_id: GobiertoCommon::Term.find(category).last_descendants }) }
    scope :with_progress, ->(progress) { where("progress > ? AND progress <= ?", *progress.split("-")) }
    scope :with_interval, ->(interval) { where("starts_at >= ? AND ends_at <= ?", *interval.split(",").map { |date| Date.parse(date) }) }

    extra_moderation_permissions_lookup_attributes do |_|
      [{
        namespace: "site_module",
        resource_name: "gobierto_plans",
        resource_id: nil
      }]
    end

    default_moderation_stage do |node|
      node.published? ? :approved : :not_sent
    end

    translates :name, :status

    enum visibility_level: { draft: 0, published: 1 }
  end
end
