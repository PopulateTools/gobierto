# frozen_string_literal: true

module GobiertoCommon
  module ActsAsTree
    extend ActiveSupport::Concern

    included do
      class_variable_set :@@parent_item_foreign_key, :parent_id
    end

    class_methods do
      def parent_item_foreign_key(name = nil)
        return class_variable_get :@@parent_item_foreign_key unless name

        class_variable_set :@@parent_item_foreign_key, name
      end

      def tree_for(item)
        where("#{table_name}.id IN (#{tree_sql_for(item)})").order("#{table_name}.id")
      end

      def tree_sql_for(item)
        <<-SQL
        WITH RECURSIVE search_tree(id, path) AS (
          SELECT id, ARRAY[id]
          FROM #{table_name}
          WHERE id = #{item.id}
            UNION ALL
          SELECT #{table_name}.id, path || #{table_name}.id
            FROM search_tree
          JOIN #{table_name} ON #{table_name}.#{parent_item_foreign_key} = search_tree.id
            WHERE NOT #{table_name}.id = ANY(path)
        )
        SELECT id FROM search_tree ORDER BY path
        SQL
      end
    end

    def descendents
      self_and_descendents - [self]
    end

    def self_and_descendents
      self.class.tree_for(self)
    end
  end
end
