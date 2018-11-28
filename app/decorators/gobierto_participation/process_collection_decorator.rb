# frozen_string_literal: true

module GobiertoParticipation
  class ProcessCollectionDecorator < BaseDecorator
    def initialize(klass, opts = {})
      @class = klass
      @item_type = opts[:item_type] || @class.name
    end

    def with_issue(issue)
      with_term(issue, :issue)
    end

    def with_scope(scope)
      with_term(scope, :scope)
    end

    private

    def with_term(term, vocabulary_association_name)
      return @class.none unless term.is_a? term_class

      item_type_scope = case @item_type
                        when "GobiertoCms::News"
                          :news_in_collections_and_container_type
                        else
                          :in_collections_and_container_type
                        end

      @class.send(item_type_scope, term.site, process_class.name)
            .joins(
              Arel.sql(
                <<-SQL
                  JOIN #{ process_class.table_name } ON #{ process_class.table_name }.id = #{ item_class.table_name }.container_id
                  JOIN #{ term_class.table_name } ON #{ term_class.table_name }.id = #{ process_class.table_name }.#{ vocabulary_association_name.to_s.foreign_key }
                  JOIN #{ vocabulary_class.table_name } ON #{ vocabulary_class.table_name }.id = #{ term_class.table_name }.vocabulary_id
                SQL
              )
            )
            .where(vocabularies: { id: process_class.send("#{ vocabulary_association_name.to_s.pluralize }_vocabulary_id", term.site) })
            .where(terms: { id: term.id })
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
  end
end
