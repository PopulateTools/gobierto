# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsFilterForm < BaseForm
      FILTER_PARAMS = %w(name permission status category progress author interval).freeze

      attr_accessor(*FILTER_PARAMS)
      attr_accessor :plan

      validates :plan, presence: true

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
            [start_interval, end_interval].join("-")
          ]
        end.unshift([I18n.t("gobierto_admin.gobierto_plans.projects.filter_form.progress"), nil])
      end

      def category_values
        plan.categories.where(level: 0).inject({}) do |data, category|
          data.update(
            category.name => OpenStruct.new(id: category.id, count: @plan.nodes.with_category(category.id).count)
          )
        end
      end

      def status_options
        []
      end

      def author_options
        []
      end

      def filter_params_values
        45
      end

      private

      def format_percentage(number)
        "#{number.to_i}%"
      end

    end
  end
end
