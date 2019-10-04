# frozen_string_literal: true

module GobiertoParticipation
  class ProcessCollectionDecorator < BaseDecorator
    def initialize(klass, opts = {})
      @class = klass
      @item_type = opts[:item_type] || @class.name
    end

    def in_participation_module(opts = {})
      private_issue_id = opts.delete(:private_issue_id)
      @class.joins(:collection).where(collection_class.table_name => { container_type: [process_class.name.deconstantize, process_class.name], item_type: @item_type })
            .joins(
              Arel.sql(
                <<-SQL
                  LEFT OUTER JOIN #{ process_class.table_name } ON #{ collection_class.table_name }.container_id = #{ process_class.table_name }.id
                SQL
              )
            )
            .where(process_class.table_name => process_visibility_options(opts))
            .where(
              if private_issue_id.present?
                Arel.sql(
                  <<-SQL
                    #{ process_class.table_name }.privacy_status = #{ process_class.privacy_statuses[:open_process] } OR
                    #{ process_class.table_name }.privacy_status IS NULL OR
                    (
                      #{ process_class.table_name }.privacy_status = #{ process_class.privacy_statuses[:closed_process] } AND
                      #{ process_class.table_name }.issue_id IS NOT NULL AND
                      #{ process_class.table_name }.issue_id = #{ private_issue_id }
                    )
                  SQL
                )
              else
                { process_class.table_name => { privacy_status: [nil, ::GobiertoParticipation::Process.privacy_statuses[:open_process]] } }
              end
            )
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
