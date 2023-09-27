# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsForm < BaseForm
      WRITABLE_ATTRIBUTES = [
        :external_id,
        :visibility_level,
        :moderation_stage,
        :name_translations,
        :minor_change,
        :category_id,
        :status_id,
        :progress,
        :starts_at,
        :ends_at,
        :position
      ].freeze

      include ::GobiertoAdmin::PermissionsGroupHelpers

      class StatusMissing < ArgumentError; end

      class CategoryMissing < ArgumentError; end

      class FailedImport < ArgumentError; end

      attr_accessor(
        :plan_id,
        :site_id,
        :projects,
        :admin
      )

      attr_writer(
        :plan,
        :site
      )

      validates :plan, :projects, presence: true

      def save
        save_plan_data if valid?
      end

      def project_form(attributes)
        NodeForm.new(form_attributes(attributes))
      end

      private

      def form_attributes(data)
        writable_attributes(data).tap do |attrs|
          attrs.merge!(plan_id:, admin:)
          if (category_id = detect_term_id(data[:category_external_id].presence || attrs[:category_id], plan.categories)).present?
            attrs[:category_id] = category_id
          end
          if (status_id = detect_term_id(data[:status_external_id].presence || attrs[:status_id], plan.statuses_vocabulary.terms)).present?
            attrs[:status_id] = status_id
          end
          attrs[:id] = plan.nodes.find_by(external_id: attrs[:external_id])&.id if attrs[:id].blank? && attrs[:external_id].present?
          visibility_level_key, version = attrs[:visibility_level].to_s.split("-")

          attrs[:moderation_visibility_level] = visibility_level_key if attrs[:visibility_level].present?
          if visibility_level_key == "published"
            if version.blank?
              attrs[:publish_last_version_automatically] = true
            else
              attrs[:disable_attributes_edition] = true
            end
          end
        end
      end

      def writable_attributes(data)
        data.slice(:id, *WRITABLE_ATTRIBUTES)
      end

      def detect_term_id(id, terms)
        return id if terms.exists?(id:)

        if id.present? && (term = terms.find_by(external_id: id)).present?
          term.id
        else
          id
        end
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def plan
        @plan ||= site.plans.find_by(id: plan_id)
      end

      def save_plan_data
        ActiveRecord::Base.transaction do
          import_nodes
          plan.touch
        end
      rescue StatusMissing, CategoryMissing, FailedImport => e
        errors.add(:base, e.class.name.demodulize.underscore.to_sym, json_data: e.message)
        false
      rescue ::GobiertoCommon::PlainCustomFieldValueDecorator::TermNotFound => e
        errors.add(:base, e.class.name.demodulize.underscore.to_sym, JSON.parse(e.message).symbolize_keys)
        false
      rescue ActiveRecord::RecordNotDestroyed
        errors.add(:base, :used_resource)
        false
      end

      def import_nodes
        projects.map do |attrs|
          form = project_form(attrs)

          if form.node.persisted?
            form.status_id = form.node.status_id if form.status_id.blank?
            form.name_translations = form.node.name_translations if form.name_translations.blank?
          else
            raise StatusMissing, attrs.to_json if form.status_id.blank?
            raise CategoryMissing, attrs.to_json if form.category_id.blank?
          end

          unless form.save
            raise FailedImport, "#{attrs.to_json} (#{form.errors.full_messages.join(" - ")})"
          end
        end
      end
    end
  end
end
