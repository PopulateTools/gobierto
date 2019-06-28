# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Node < ApplicationRecord
    include GobiertoCommon::Moderable
    include GobiertoCommon::HasVocabulary

    belongs_to :author, class_name: "GobiertoAdmin::Admin", foreign_key: :admin_id
    has_and_belongs_to_many :categories, class_name: "GobiertoCommon::Term", association_foreign_key: :category_id, join_table: :gplan_categories_nodes

    has_paper_trail skip: [:visibility_level, :published_version]
    has_vocabulary :statuses
    belongs_to :status, class_name: "GobiertoCommon::Term"

    delegate :name, to: :status, prefix: true

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
    scope :with_admin_actions, lambda { |admin|
      admin_id, action_name, site_id = admin.to_s.split("-")
      admin = GobiertoAdmin::Admin.find(admin_id)
      site = Site.find_by(id: site_id)
      if action_name.present? && GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(current_admin: admin, current_site: site).allowed_actions.include?(action_name.to_sym)
        all
      else
        where(author: admin)
      end
    }

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

    translates :name

    enum visibility_level: { draft: 0, published: 1 }
  end
end
