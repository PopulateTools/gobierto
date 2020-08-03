# frozen_string_literal: true

module GobiertoBudgets
  module BudgetLinePgSearchHelpers
    extend ActiveSupport::Concern

    class_methods do
      def pg_search_reindex_collection(budget_lines)
        budget_lines.each do |budget_line|
          pg_search_reindex(budget_line)
        end
      end

      def pg_search_reindex(budget_line)
        document = budget_line.site.pg_search_documents.find_or_initialize_by(
          searchable_type: budget_line.class.name,
          external_id: budget_line.external_id
        )
        document.assign_attributes(
          budget_line.translated_attributes.merge(
            content: budget_line.searchable_content,
            resource_path: budget_line.resource_path,
            meta: budget_line.search_meta
          )
        )
        document.save
      end

      def pg_search_delete_index(budget_line)
        document = budget_line.site.pg_search_documents.find_by(
          searchable_type: budget_line.class.name,
          external_id: budget_line.external_id
        )&.destroy
      end
    end

    included do
      def external_id
        "#{index}/#{area.area_name}/#{organization_id}/#{year}/#{code}/#{kind}"
      end

      def search_meta
        { index: index, type: area.area_name, organization_id: organization_id, year: year, code: code, kind: kind }
      end

      def translated_attributes
        translations = { "title_translations" => {}, "description_translations" => {} }

        I18n.available_locales.each do |locale|
          I18n.with_locale(locale) do
            translations["title_translations"][locale] = get_name
            translations["description_translations"][locale] = get_description
          end
        end

        translations
      end

      def resource_path
        Rails.application.routes.url_helpers.gobierto_budgets_budget_line_path(area_name: area.area_name, kind: kind, year: year, id: code)
      end

      def searchable_content
        translated_attributes.values.map{ |translations| translations.values.join(" ") }.join(" ")
      end
    end

  end
end
