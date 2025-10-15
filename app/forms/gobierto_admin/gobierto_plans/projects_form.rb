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

      CUSTOM_FIELD_WRITABLE_TYPES = [
        :vocabulary_options,
        :string,
        :paragraph,
        :date
      ].freeze

      include ::GobiertoAdmin::PermissionsGroupHelpers
      include ::GobiertoPlans::VersionsHelpers

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

      def custom_field_records_values(data)
        custom_fields_attributes.each_with_object({}) do |(key, custom_field), values|
          value_decorator = ::GobiertoCommon::PlainCustomFieldValueDecorator.new(custom_field)
          value_decorator.allow_vocabulary_terms_creation = true
          value_decorator.plain_text_value = data[key]
          I18n.with_locale(default_locale) do
            values[custom_field.uid] = value_decorator.value
          end
        end
      end

      private

      def form_attributes(data)
        writable_attributes(data).tap do |attrs|
          attrs.merge!(plan_id:, admin:)
          attrs.merge!(allowed_actions)
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

      def allowed_actions
        admin_actions_manager = ::GobiertoAdmin::AdminActionsManager.for("gobierto_plans", site)
        lists = admin_actions_manager.admin_actions(admin: admin, resource: plan.nodes)

        {
          allowed_admin_actions: lists.dig(:default, :admin_actions) ,
          allowed_controller_actions: lists.dig(:default, :controller_actions)
        }
      end

      def default_locale
        @default_locale ||= site.configuration.default_locale || site.configuration.available_locales.first || I18n.available_locales.first
      end

      def writable_attributes(data)
        data.slice(:id, *WRITABLE_ATTRIBUTES)
      end

      def custom_fields_attributes
        @custom_fields_attributes ||= {}.tap do |hsh|
          CUSTOM_FIELD_WRITABLE_TYPES.each do |type|
            custom_fields.send(type).each do |field|
              hsh["custom_field_#{type}_#{field.uid.underscore}"] = field
            end
          end
        end
      end

      def custom_fields
        @custom_fields ||= plan.available_custom_fields.where(instance: plan)
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
          new_node_version = true

          if form.node.persisted?
            form.status_id = form.node.status_id if form.status_id.blank?
            form.name_translations = form.node.name_translations if form.name_translations.blank?
            new_node_version = new_node_version?(form)
          else
            raise StatusMissing, attrs.to_json if form.status_id.blank?
            raise CategoryMissing, attrs.to_json if form.category_id.blank?
          end

          if form.save && save_custom_fields(form.node, attrs, new_node_version)
            set_publication(form.node)
            set_permissions_group(form.node, action_name: :edit)
          else
            raise FailedImport, "#{attrs.to_json} (#{form.errors.full_messages.join(" - ")})"
          end
        end
      end

      def save_custom_fields(node, attrs, new_node_version)
        custom_fields_form = ::GobiertoCommon::CustomFieldRecordsForm.new(
          site_id: site.id,
          item: node,
          instance: plan,
          with_version: true,
          version_index: 0
        )

        custom_fields_form.custom_field_records = custom_field_records_values(attrs)

        new_version = plan.nodes.exists? && (custom_fields_form.changed? || new_node_version)
        custom_fields_form.force_new_version = new_version
        node.touch if new_version && !new_node_version

        custom_fields_form.save
      end

      def new_node_version?(form)
        versioned_attributes = ::GobiertoPlans::Node::VERSIONED_ATTRIBUTES
        form.node.slice(versioned_attributes) != versioned_attributes.each_with_object({}) { |attr, hsh| hsh[attr] = form.send(attr) }
      end
    end
  end
end
