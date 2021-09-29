# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Annual
      class UnsupportedFormat < StandardError; end

      FORMATS = {
        json: { serializer: ->(data) { data.to_json },
                content_type: "application/json; charset=utf-8" },
        csv:  { serializer: ->(data) { GobiertoExports::CSVRenderer.new(data).to_csv },
                content_type: "text/csv; charset=utf-8" }
      }.freeze

      attr_accessor :site, :year

      def initialize(options = {})
        @year = options[:year]
        @site = options[:site]
      end

      def any_data?
        GobiertoBudgets::BudgetLine.any_data?(site: site, year: year)
      end

      def get_url(format)
        file = GobiertoCommon::FileUploadService.new(file_name: filename(format))
        file.uploaded_file_exists? && file.call
      end

      def generate_files
        file_urls = []
        return file_urls unless any_data?
        calculate_organization_budget_lines

        FORMATS.each do |format_key, configuration|
          file_urls << GobiertoCommon::FileUploadService.new(
            file_name: filename(format_key),
            content: configuration[:serializer].call(@organization_budget_lines),
            content_type: configuration[:content_type]
          ).upload!
        end
        file_urls
      end

      protected

      def filename(format)
        raise UnsupportedFormat unless FORMATS.keys.include?(format.to_sym)
        ["gobierto_budgets", site.organization_id, "data", "annual", "#{ year }.#{ format }"].join("/")
      end

      def calculate_organization_budget_lines
        presenter = GobiertoBudgets::BudgetLineExportPresenter
        indexes = presenter::INDEX_KEYS

        GobiertoBudgets::BudgetLine.all_kinds. each do |kind|
          indexes.each_key do |index|
            GobiertoBudgets::BudgetArea.all_areas.each do |area|
              next unless area.available_kinds.include?(kind)

              budget_lines = GobiertoBudgets::BudgetLine.all(where: { year: year,
                                                                      site: site,
                                                                      area_name: area.area_name,
                                                                      kind: kind,
                                                                      index: index },
                                                                      include: [:index, :updated_at],
                                                                      presenter: presenter)
              merge_budget_lines(budget_lines)
            end

            functional_code_budget_lines = GobiertoBudgets::BudgetLine.all(where: { year: year,
                                                                                    site: site,
                                                                                    area_name: GobiertoBudgets::FunctionalArea.area_name,
                                                                                    kind: kind,
                                                                                    index: index,
                                                                                    functional_code: nil },
                                                                                    include: [:index, :updated_at],
                                                                                    presenter: presenter)

            custom_code_budget_lines = GobiertoBudgets::BudgetLine.all(where: { year: year,
                                                                                site: site,
                                                                                area_name: GobiertoBudgets::CustomArea.area_name,
                                                                                kind: kind,
                                                                                index: index,
                                                                                custom_code: nil },
                                                                                include: [:index, :updated_at],
                                                                                presenter: presenter)
              merge_budget_lines(functional_code_budget_lines)
              merge_budget_lines(custom_code_budget_lines)
          end
        end
      end

      def merge_budget_lines(budget_lines)
        @organization_budget_lines ||= []

        budget_lines.each do |line|
          if (idx = @organization_budget_lines.index { |global_line| global_line.id == line.id })
            @organization_budget_lines[idx].merge!(line)
          else
            @organization_budget_lines << line
          end
        end
      end
    end
  end
end
