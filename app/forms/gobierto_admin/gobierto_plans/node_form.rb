# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class NodeForm < BaseForm

      attr_accessor(
        :id,
        :plan_id,
        :name_translations,
        :status_translations,
        :progress,
        :starts_at,
        :ends_at,
        :options_json,
        :admin
      )
      attr_writer(
        :category_id,
        :visibility_level,
        :moderation_visibility_level,
        :moderation_stage,
        :disable_attributes_edition
      )

      validates :plan, :admin, presence: true
      validates :category, :name_translations, presence: true, if: -> { allow_edit_attributes? }
      validate :options_json_format

      delegate :persisted?, to: :node
      delegate :site_id, to: :plan

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
                                  ["#{"--" * term.level} #{term.name}".strip, term.level == enabled_level ? term.id : "disabled"]
                                end
                              end
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

      def moderation_stage
        @moderation_stage ||= node.moderation_stage
      end

      def allow_edit_attributes?
        moderation_policy.edit? && !disable_attributes_edition
      end

      def allow_moderate?
        moderation_policy.moderate?
      end

      def moderation_visibility_level
        moderation_policy.moderate? ? @moderation_visibility_level : nil
      end

      private

      def disable_attributes_edition
        @disable_attributes_edition && moderation_policy.moderate?
      end

      def moderation_policy
        @moderation_policy ||= GobiertoAdmin::ModerationPolicy.new(current_admin: admin, current_site: site, moderable: node)
      end

      def build_node
        ::GobiertoPlans::Node.new(admin_id: admin.id)
      end

      def check_visibility_level
        return if moderation_policy.blank? || node.visibility_level == visibility_level || moderation_policy.publish_as_editor? || moderation_visibility_level.present?

        @visibility_level = node.visibility_level
        @moderation_stage = node.moderation.available_stages_for_action(:edit).keys.first
      end

      def options_json_format
        return if options_json.blank? || options_json.is_a?(Hash)

        JSON.parse(options_json)
      rescue JSON::ParserError
        errors.add :options_json, I18n.t("errors.messages.invalid")
      end

      def save_node
        @node = node.tap do |attributes|
          if allow_edit_attributes?
            attributes.name_translations = name_translations
            attributes.status_translations = status_translations
            attributes.progress = progress
            attributes.starts_at = starts_at
            attributes.ends_at = ends_at
            attributes.options = options
          end
          attributes.visibility_level = visibility_level
        end

        if @node.valid?
          @node.save
          if allow_edit_attributes? && !@node.categories.include?(category)
            @node.categories.where(vocabulary: plan.categories_vocabulary).each do |plan_category|
              @node.categories.delete plan_category
            end
            node.categories << category
          end

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
    end
  end
end
