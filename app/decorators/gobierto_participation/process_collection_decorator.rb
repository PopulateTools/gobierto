# frozen_string_literal: true

module GobiertoParticipation
  class ProcessCollectionDecorator < BaseDecorator
    def initialize(klass, opts = {})
      @class = klass
      @item_type = opts[:item_type] || @class.name
    end

    def in_participation_module(opts = {})
      @class.joins(:collection).where(collection_class.table_name => { container_type: [process_class.name.deconstantize, process_class.name], item_type: @item_type })
            .joins(
              Arel.sql(
                <<-SQL
                  LEFT OUTER JOIN #{ process_class.table_name } ON #{ collection_class.table_name }.container_id = #{ process_class.table_name }.id
                SQL
              )
            )
            .where(process_class.table_name => process_visibility_options(opts))
    end

    def in_process(process, opts = {})
      in_participation_module(opts).where(collection_class.table_name => { container_id: process.id })
    end

    def with_term(term, opts = {})
      returt @class.none unless term.is_a? term_class

      vocabulary_association_name = ProcessTermDecorator.new(term).send(:association_with_processes)

      in_participation_module(opts)
        .joins(
          Arel.sql(
            <<-SQL
              JOIN #{ term_class.table_name } ON #{ term_class.table_name }.id = #{ process_class.table_name }.#{ vocabulary_association_name.to_s.foreign_key }
              JOIN #{ vocabulary_class.table_name } ON #{ vocabulary_class.table_name }.id = #{ term_class.table_name }.vocabulary_id
            SQL
          )
        )
        .where(vocabularies: { id: process_class.send("#{ vocabulary_association_name.to_s.pluralize }_vocabulary_id", term.site) })
        .where(terms: { id: term.id })
    end

    private

    def process_visibility_options(opts)
      {}.tap do |visibility_options|
        visibility_options[:archived_at] = nil unless opts[:with_archived]
        visibility_options[:visibility_level] = [process_class.visibility_levels[:active], nil] unless opts[:with_draft]
      end
    end

    def process_class
      GobiertoParticipation::Process
    end

    def item_class
      GobiertoCommon::CollectionItem
    end

    def term_class
      GobiertoCommon::Term
    end

    def vocabulary_class
      GobiertoCommon::Vocabulary
    end

    def collection_class
      GobiertoCommon::Collection
    end
  end
end
