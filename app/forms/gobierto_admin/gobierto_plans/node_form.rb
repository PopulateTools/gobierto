# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class NodeForm < BaseForm
      include ::GobiertoAdmin::PermissionsGroupHelpers

      attr_accessor(
        :id,
        :plan_id,
        :name_translations,
        :starts_at,
        :ends_at,
        :options_json,
        :admin,
        :position,
        :force_new_version
      )
      attr_writer(
        :category_id,
        :status_id,
        :visibility_level,
        :moderation_visibility_level,
        :moderation_stage,
        :disable_attributes_edition,
        :progress,
        :published_version,
        :version,
        :external_id,
        :publish_last_version_automatically,
        :minor_change
      )
      attr_reader :allowed_admin_actions
      attr_reader :allowed_controller_actions

      validates :plan, :admin, presence: true
      validates :progress, presence: true, if: -> { @passed_attributes.include?("progress") }
      validates :category, :name_translations, presence: true, if: -> { allow_edit_attributes? }
      validates :status_id, presence: true, if: -> { allow_edit_attributes? && statuses_vocabulary.present? }
      validate :options_json_format
      validate :external_id_uniqueness_by_plan

      delegate :persisted?, to: :node
      delegate :site_id, :statuses_vocabulary, to: :plan

      def initialize(options = {})
        options = options.to_h.with_indifferent_access
        @allowed_admin_actions = options.delete(:allowed_admin_actions)
        @allowed_controller_actions = options.delete(:allowed_controller_actions)
        ordered_options = options.slice(:id, :plan_id, :admin).merge!(options)
        @passed_attributes = ordered_options.keys
        @publication_updated = false
        super(ordered_options)
        @new_record = node.new_record?
        set_publication_version
      end

      def save
        check_visibility_level if allow_edit_attributes?

        save_node if valid?
      end

      def plan
        @plan ||= ::GobiertoPlans::Plan.find_by(id: plan_id)
      end

      def site
        Site.find_by(id: site_id)
      end

      def node
        @node ||= ::GobiertoPlans::Node.find_by(id: id).presence || build_node
      end
      alias record node
      alias project node

      def category
        @category ||= plan.categories.find_by(id: category_id)
      end

      def category_id
        @category_id ||= node.categories.where(vocabulary: plan.categories_vocabulary).first&.id
      end

      def category_options
        @category_options ||= begin
                                enabled_level = plan.categories_vocabulary.maximum_level
                                plan.categories_vocabulary.ordered_flatten_terms_tree.map do |term|
                                  [ActiveSupport::SafeBuffer.new("#{"&nbsp;" * 6 * term.level} #{term.name}".strip), term.level == enabled_level ? term.id : "disabled"]
                                end
                              end
      end

      def statuses_options
        @statuses_options ||= plan.statuses_vocabulary.terms.sorted.map { |term| [term.name, term.id] }
      end

      def progress_options
        @progress_options ||= begin
                                divisions = 4
                                (0..divisions).map do |div|
                                  progress_option(div.to_f / divisions * 100.0)
                                end +
                                  [["- - - -", "disabled"]] +
                                  (0..100).map { |percentage| progress_option(percentage) }
                              end
      end

      def progress_value
        @progress_value ||= progress.present? ? progress.to_i.to_s : nil
      end

      def options
        @options ||= begin
                       return nil if options_json.blank?

                       JSON.parse(options_json)
                     end
      end

      def visibility_level
        @visibility_level ||= moderation_visibility_level || node.visibility_level || "draft"
      end

      def progress
        @progress ||= node.progress || 0.0
      end

      def moderation_stage
        @moderation_stage ||= if reset_moderation?
                                :unsent
                              elsif publication_reset_moderation?
                                :approved
                              else
                                node.moderation_stage
                              end
      end

      def allow_edit_attributes?
        !disable_attributes_edition && allowed_admin_actions.include?(:edit_projects) || allowed_controller_actions.include?(:create) && @new_record
      end

      def reset_moderation?
        @reset_moderation ||= moderation_not_allowed? && attributes_updated? && !node.moderation.unsent?
      end

      def publication_reset_moderation?
        @publication_reset_moderation ||= publication_updated? && moderation_not_allowed? && visibility_level == "published"
      end

      def moderation_not_allowed?
        @moderation_not_allowed ||= allowed_admin_actions.exclude?(:moderate_projects)
      end

      def allow_publish?
        allowed_admin_actions.include?(:publish_projects)
      end

      def allow_manage_admin_groups?
        allowed_admin_actions.include?(:manage)
      end

      def moderation_visibility_level
        moderation_policy.moderate? ? @moderation_visibility_level : nil
      end

      def status_id
        return unless statuses_vocabulary && statuses_vocabulary.terms.where(id: @status_id).exists?

        @status_id
      end

      def attributes_updated?
        return unless allow_edit_attributes?

        @attributes_updated ||= @new_record || nodes_attributes_differ?(set_node_attributes, versioned_node)
      end

      def publication_updated?
        @publication_updated
      end

      def version_index
        return unless @version && @version.to_i < node.versions.length

        @version.to_i - node.versions.length
      end

      def external_id
        @external_id ||= node.external_id || node.scoped_new_external_id(plan.nodes)
      end

      def publish_last_version_automatically
        return true if @publish_last_version_automatically.is_a? TrueClass

        @publish_last_version_automatically == "1"
      end

      def minor_change
        return true if @minor_change.is_a? TrueClass

        @minor_change == "1"
      end

      private

      def has_versions?
        @has_versions ||= node.respond_to?(:paper_trail)
      end

      def set_publication_version
        return if @version.present? || !has_versions?

        @visibility_level, @version = visibility_level.to_s.split("-")

        @version ||= if node.versions.present? && publish_last_version_automatically
                       node.versions.length
                     elsif @visibility_level == "published" && @new_record
                       1
                     end

        @published_version = @visibility_level == "published" ? (@version || node.published_version).to_i : nil
      end

      def disable_attributes_edition
        @disable_attributes_edition && allowed_admin_actions.include?(:publish_projects)
      end

      def moderation_policy
        @moderation_policy ||= GobiertoAdmin::ModerationPolicy.new(current_admin: admin, current_site: site, moderable: node)
      end

      def build_node
        ::GobiertoPlans::Node.new(admin_id: admin.id)
      end

      def check_visibility_level
        return if moderation_policy.blank? || node.visibility_level == visibility_level || moderation_policy.publish? || moderation_policy.publish_as_editor? || moderation_visibility_level.present?

        @visibility_level = node.visibility_level
        @moderation_stage = node.moderation.available_stages_for_action(:edit).keys.first
      end

      def options_json_format
        return if options_json.blank? || options_json.is_a?(Hash)

        JSON.parse(options_json)
      rescue JSON::ParserError
        errors.add :options_json, I18n.t("errors.messages.invalid")
      end

      def external_id_uniqueness_by_plan
        errors.add :external_id, I18n.t("errors.messages.taken") if plan.nodes.where.not(id: node.id).where(external_id: external_id).exists?
      end

      def versioned_node
        return node.clone.reload unless version_index

        node.versions[version_index].reify
      end

      def nodes_attributes_differ?(node_a, node_b)
        node_a.attributes.slice(*attributes_for_new_version) != node_b.attributes.slice(*attributes_for_new_version)
      end

      def set_node_attributes
        return unless allow_edit_attributes?

        @node.tap do |attributes|
          attributes.name_translations = name_translations
          attributes.progress = progress
          attributes.starts_at = starts_at
          attributes.ends_at = ends_at
          attributes.options = options
          attributes.status_id = status_id
          attributes.external_id = external_id
          attributes.minor_change = minor_change
        end
      end

      def set_version_and_visibility_level
        node.tap do |attributes|
          if allow_edit_attributes? && @version.present?
            if attributes_updated? || force_new_version
              @published_version = attributes.versions.length + (minor_change ? 0 : 1)
            else
              attributes.reload
            end
          end

          attributes.visibility_level = visibility_level
          attributes.published_version = @published_version
          @publication_updated = attributes.visibility_level_changed?
        end
      end

      def set_category
        return unless allow_edit_attributes? && !@node.categories.include?(category)

        @node.categories.where(vocabulary: plan.categories_vocabulary).each do |plan_category|
          @node.categories.delete plan_category
        end
        node.categories << category
      end

      def save_node
        set_node_attributes
        attributes_updated?
        set_version_and_visibility_level

        if @node.valid?
          @node.restore_attributes(ignored_attributes) if @node.changed? && ignored_attributes.present?
          @node.save
          @node.touch if force_new_version && !attributes_updated?

          # Do not set permissions for this group
          set_permissions_group(@node, action_name: nil) do |group|
            group.admins << @node.owner unless @node.owner.blank? || group.admins.where(id: @node.admin_id).exists?
          end

          set_category

          # Update plan cache
          plan.touch

          save_moderation

          @node
        else
          promote_errors(@node.errors)

          false
        end
      end

      def save_moderation
        return true unless moderation_policy.present? && moderation_policy.moderable_has_moderation?

        node.moderation.tap do |attributes|
          attributes.site_id = site_id
          attributes.admin = admin
          attributes.stage = moderation_stage if moderation_stage.present?
        end.save
      end

      def progress_option(number)
        ["#{number.to_i}%", number.to_i]
      end

      def attributes_for_new_version
        @attributes_for_new_version ||= version_attributes & @passed_attributes
      end

      def version_attributes
        ::GobiertoPlans::Node::VERSIONED_ATTRIBUTES
      end

      def ignored_attributes
        @ignored_attributes ||= version_attributes - @passed_attributes
      end
    end
  end
end
