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
        :options_json
      )
      attr_writer(
        :category_id,
        :visibility_level
      )

      validates :plan, :category, :name_translations, presence: true
      validate :options_json_format

      delegate :persisted?, to: :node

      def save
        save_node if valid?
      end

      def plan
        @plan ||= ::GobiertoPlans::Plan.find_by(id: plan_id)
      end

      def node
        @node ||= ::GobiertoPlans::Node.find_by(id: id).presence || build_node
      end
      alias record node

      def category
        @category ||= plan.categories.find_by(id: category_id)
      end

      def category_id
        @category_id ||= node.categories.where(vocabulary: plan.categories_vocabulary).first&.id
      end

      def category_options
        @category_options ||= plan.categories.where(level: plan.categories_vocabulary.maximum_level).sorted.map do |category|
          [category.name, category.id]
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
        @visibility_level ||= "draft"
      end

      private

      def build_node
        ::GobiertoPlans::Node.new
      end

      def options_json_format
        return if options_json.blank? || options_json.is_a?(Hash)

        JSON.parse(options_json)
      rescue JSON::ParserError
        errors.add :options_json, I18n.t("errors.messages.invalid")
      end

      def save_node
        @node = node.tap do |attributes|
          attributes.name_translations = name_translations
          attributes.status_translations = status_translations
          attributes.progress = progress
          attributes.starts_at = starts_at
          attributes.ends_at = ends_at
          attributes.options = options
        end

        if @node.valid?
          @node.save
          unless @node.categories.include? category
            @node.categories.where(vocabulary: plan.categories_vocabulary).each do |plan_category|
              @node.categories.delete plan_category
            end
            node.categories << category
          end

          @node
        else
          promote_errors(@node.errors)

          false
        end
      end

      def progress_option(number)
        ["#{number.to_i}%", number.to_i]
      end
    end
  end
end
