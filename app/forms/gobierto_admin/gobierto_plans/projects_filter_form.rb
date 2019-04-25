# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsFilterForm < BaseForm
      FILTER_PARAMS = %w(name admin_actions category progress author moderation_stage interval).freeze

      attr_accessor(*FILTER_PARAMS)
      attr_accessor :plan, :admin

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
        { owned: OpenStruct.new(id: admin.id, count: @plan.nodes.with_admin_actions(admin.id).count),
          can_edit: OpenStruct.new(id: "#{admin.id}-edit", count: @plan.nodes.with_admin_actions("#{admin.id}-edit").count) }
      end

      def admin_actions_all_value
        @plan.nodes.count
      end

      def moderation_stage_values
        stages = ::GobiertoPlans::Node.moderation_stages.keys
        stages.unshift(:blank) if @plan.nodes.with_moderation_stage(:blank).exists?
        stages.inject({}) do |data, stage_name|
          data.update(
            stage_name => OpenStruct.new(id: stage_name, count: @plan.nodes.with_moderation_stage(stage_name).count)
          )
        end
      end

      def author_options
        @plan.nodes.select(:admin_id).distinct.pluck(:admin_id).compact.map do |admin_id|
          [GobiertoAdmin::Admin.find(admin_id).name, admin_id]
        end.unshift([I18n.t("gobierto_admin.gobierto_plans.projects.filter_form.author"), nil])
      end

      private

      def format_percentage(number)
        "#{number.to_i}%"
      end

    end
  end
end
