# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsFilterForm < BaseForm
      FILTER_PARAMS = %w(name admin_actions category progress author moderation_stage start_date end_date interval status).freeze

      attr_accessor(*FILTER_PARAMS)
      attr_accessor :plan, :admin, :permissions_policy

      validates :plan, :admin, presence: true

      delegate :persisted?, to: :plan

      def site
        @site ||= plan.site
      end

      def filter_params
        @filter_params ||= FILTER_PARAMS.select do |param|
          send(param).present?
        end
      end

      def category_options
        plan.categories.where(level: 0).map do |category|
          [category.name, category.id]
        end.unshift([I18n.t("gobierto_admin.gobierto_plans.projects.filter_form.category"), nil])
      end

      def progress_options
        divisions = 4
        (0..divisions - 1).map do |div|
          start_interval = div.to_f / divisions * 100.0
          end_interval = (1 + div.to_f) / divisions * 100.0
          [
            [format_percentage(start_interval + (div.positive? ? 1 : 0)), format_percentage(end_interval)].join(" - "),
            [div.positive? ? start_interval : -1.0, end_interval].join(" - ")
          ]
        end.unshift([I18n.t("gobierto_admin.gobierto_plans.projects.filter_form.progress"), nil])
      end

      def admin_actions_values
        { owned: OpenStruct.new(id: admin.id, count: editor_relation.with_author(admin.id).count),
          can_edit: OpenStruct.new(id: "#{admin.id}-edit", count: editor_relation.count) }
      end

      def admin_actions_all_value
        base_relation.count
      end

      def moderation_stage_values
        stages = ::GobiertoPlans::Node.moderation_stages.keys
        stages.unshift(:blank) if base_relation.with_moderation_stage(:blank).exists?
        stages.inject({}) do |data, stage_name|
          data.update(
            stage_name => OpenStruct.new(id: stage_name, count: base_relation.with_moderation_stage(stage_name).count)
          )
        end
      end

      def author_options
        base_relation.distinct(false).pluck(:admin_id).uniq.compact.map do |admin_id|
          [GobiertoAdmin::Admin.find(admin_id).name, admin_id]
        end.unshift([I18n.t("gobierto_admin.gobierto_plans.projects.filter_form.author"), nil])
      end

      def status_options
        return unless @plan.statuses_vocabulary.present?

        @plan.statuses_vocabulary.terms.map do |status|
          [status.name, status.id]
        end.unshift([I18n.t("gobierto_admin.gobierto_plans.projects.filter_form.status"), nil])
      end

      def base_relation
        @base_relation ||= if permissions_policy.allowed_actions_by_scope(:all).include?(:index)
                             @plan.nodes
                           elsif permissions_policy.allowed_actions_by_scope(:assigned).include?(:index)
                             assigned_resources
                           else
                             @plan.nodes.none
                           end
      end

      def editor_relation
        @editor_relation ||= if permissions_policy.allowed_actions_by_scope(:all).include?(:edit)
                               @plan.nodes
                             elsif permissions_policy.allowed_actions_by_scope(:assigned).include?(:edit)
                               assigned_resources
                             else
                               @plan.nodes.none
                             end
      end

      private

      def format_percentage(number)
        "#{number.to_i}%"
      end

      def assigned_resources
        @assigned_resources ||= GobiertoAdmin::AdminResourcesQuery.new(admin, relation: @plan.nodes).allowed(include_moderated: false)
      end
    end
  end
end
