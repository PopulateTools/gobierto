# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Annual
      class UnsupportedFormat < StandardError; end

      FORMATS = {
        json: { serializer: ->(data) { data.to_json },
                content_type: 'application/json; charset=utf-8' },
        csv:  { serializer: ->(data) { GobiertoExports::CSVRenderer.new(data).to_csv },
                content_type: 'text/csv; charset=utf-8' }
      }

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
        calculate_place_budget_lines

        FORMATS.each do |format_key, configuration|
          file_urls << GobiertoCommon::FileUploadService.new(
            file_name: filename(format_key),
            content: configuration[:serializer].call(@place_budget_lines),
            content_type: configuration[:content_type]
          ).upload!
        end
        file_urls
      end

      protected

      def place
        site.place
      end

      def filename(format)
        raise UnsupportedFormat if !FORMATS.keys.include?(format.to_sym)
        ["gobierto_budgets", place.id, "data", "annual", "#{year}.#{format}"].join("/")
      end

      def calculate_place_budget_lines
        presenter = GobiertoBudgets::BudgetLineExportPresenter
        indexes = presenter::INDEX_KEYS

        @place_budget_lines = []
        GobiertoBudgets::BudgetLine.all_kinds. each do |kind|
          GobiertoBudgets::BudgetArea.all_areas.each do |area|
            indexes.each_key do |index|
              next unless area.available_kinds.include?(kind)
              index_budget_lines = GobiertoBudgets::BudgetLine.all(where: { year: year,
                                                                            site: site,
                                                                            place: place,
                                                                            area_name: area.area_name,
                                                                            kind: kind,
                                                                            index: index },
                                                                            include: [:index, :updated_at],
                                                                            presenter: presenter)
              index_budget_lines.each do |line|
                if (idx = @place_budget_lines.index { |global_line| global_line.id == line.id })
                  @place_budget_lines[idx].merge!(line)
                else
                  @place_budget_lines << line
                end
              end
            end
          end
        end
      end
    end
  end
end
