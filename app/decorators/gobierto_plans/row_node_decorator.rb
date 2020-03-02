# frozen_string_literal: true

module GobiertoPlans
  class RowNodeDecorator < BaseDecorator
    attr_reader :status_missing

    STATUS_TRANSLATIONS = {
      %w(finalitzats terminada completado) => 100.0,
      %w(actius en\ ejecución) => 50.0,
      %w(empezada iniciado) => 10.0,
      %w(en\ cartera pendiente\ de\ iniciar planificada aplazada) => 0.0
    }.freeze

    def initialize(object, options = {})
      if object.is_a? CSV::Row
        @object = object
        @plan = options[:plan]
      elsif object.is_a? Node
        @node = object
        @plan = CategoryTermDecorator.new(@node.categories.first).plan
        @category = node_category
        @object = CSV::Row.new(plan_csv_columns, node_csv_values)
      elsif object.is_a? GobiertoCommon::Term
        @category = CategoryTermDecorator.new(object)
        @plan = @category.plan
        @node = Node.new(progress: nil)
        @object = CSV::Row.new(plan_csv_columns, node_csv_values)
      end
    end

    def categories
      @categories ||= begin
                        level_names = object.headers.select { |h| /Level \d+/.match(h) }.sort_by { |h| h[/\d+/].to_i }
                        current_level = @plan
                        categories = []
                        level_names.each_with_index do |name, index|
                          current_level =
                            current_level.categories.where("#{ terms_table_name }.name_translations @> ?::jsonb", { locale => object[name] }.to_json).first ||
                            current_level.categories.new(
                              "name_#{ locale }": object[name],
                              level: index,
                              vocabulary_id: @plan.categories_vocabulary.id
                            )
                          current_level = CategoryTermDecorator.new(current_level)
                          categories << current_level
                        end
                        categories
                      end
    end

    def node
      @node ||= begin
                  return nil if node_data.compact.blank?

                  category = CategoryTermDecorator.new(categories.last)
                  (category.nodes.where("#{ nodes_table_name }.name_translations @> ?::jsonb", { locale => node_data["Title"] }.to_json).first || category.nodes.new).tap do |node|
                    node.assign_attributes node_attributes.except(:status_name)
                    node.progress = progress_from_status(node.status.name) unless has_progress_column?
                    node.progress ||= 0.0
                    node.visibility_level = :published
                    node.published_version = 1
                    node.build_moderation(stage: :approved)
                    node.categories << category unless node.categories.include?(category)
                  end
                end
    end

    def status_term_required?
      @plan.statuses_vocabulary.present?
    end

    def extra_attributes
      node_data.except("Title", "Status", "Start", "End", "Progress")
    end

    def custom_field_records_values
      extra_attributes.inject({}) do |values, (uid, plain_text_value)|
        next(values) unless plan_custom_fields_keys.include?(uid)

        value_decorator = ::GobiertoCommon::PlainCustomFieldValueDecorator.new(custom_fields.find_by(uid: uid))
        value_decorator.allow_vocabulary_terms_creation = true
        value_decorator.plain_text_value = plain_text_value
        values.update(
          uid => value_decorator.value
        )
      end
    end

    protected

    def node_data
      @node_data ||= prefixed_row_data(/\ANode\./)
    end

    def prefixed_row_data(prefix)
      object.headers.select { |h| prefix.match(h) }.map do |h|
        [h.sub(prefix, ""), object[h]]
      end.to_h
    end

    def has_progress_column?
      node_data.has_key? "Progress"
    end

    def locale
      @locale ||= @plan.site.configuration.default_locale
    end

    def node_attributes
      attributes = node_mandatory_columns.invert.transform_values { |column| object[column] }

      attributes[:status_id] = @plan.statuses_vocabulary.terms.with_name(attributes[:status_name]&.strip).take&.id if status_term_required?
      @status_missing = status_term_required? ? attributes[:status_id].blank? : attributes[:status_name].present?

      attributes
    end

    def progress_from_status(status)
      return if status.blank?

      status = status.strip.downcase
      key = STATUS_TRANSLATIONS.keys.find { |k| k.include?(status) }
      STATUS_TRANSLATIONS[key]
    end

    def node_mandatory_columns
      @node_mandatory_columns ||= { "Node.Title" => :"name_#{ locale }",
                                    "Node.Status" => :status_name,
                                    "Node.Progress" => :progress,
                                    "Node.Start" => :starts_at,
                                    "Node.End" => :ends_at }
    end

    def plan_custom_fields_keys
      @plan_custom_fields_keys ||= custom_fields.map(&:uid)
    end

    def custom_fields
      @custom_fields ||= ::GobiertoCommon::CustomFieldRecordsForm.new(
        item: Node.new,
        instance: @plan,
        site_id: @plan.site_id
      ).available_custom_fields.where(
        field_type: ::GobiertoCommon::CustomField.csv_importable_field_types
      )
    end

    def plan_nodes_extra_columns
      plan_custom_fields_keys.map do |key|
        "Node.#{ key }"
      end
    end

    def plan_csv_columns
      plan_categories_range.map { |num| "Level #{ num }" } +
        node_mandatory_columns.keys +
        plan_nodes_extra_columns
    end

    def plan_categories_range
      @plan.categories.minimum(:level)..@plan.categories.maximum(:level)
    end

    def categories_hierarchy(category)
      categories = []
      while category.present?
        categories.unshift(CategoryTermDecorator.new(category))
        category = category.parent_term
      end
      categories
    end

    def node_category
      CategoryTermDecorator.new(@node.categories.where(level: @plan.categories.maximum(:level)).first)
    end

    def node_mandatory_values
      node_mandatory_columns.map do |_, method|
        @node.send(method)
      end
    end

    def category_values
      categories_hierarchy(@category).map do |category|
        category.send(:"name_#{ @locale }")
      end
    end

    def node_extra_values
      custom_fields.map do |custom_field|
        node.custom_field_records.find_by(custom_field: custom_field)&.value_string
      end
    end

    def nodes_table_name
      Node.table_name
    end

    def terms_table_name
      GobiertoCommon::Term.table_name
    end

    def node_csv_values
      category_values + node_mandatory_values + node_extra_values
    end
  end
end
