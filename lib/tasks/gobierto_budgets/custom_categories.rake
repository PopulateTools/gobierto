# frozen_string_literal: true

require "#{Rails.root}/lib/utils/csv_utils"

namespace :gobierto_budgets do
  namespace :custom_categories do
    desc "Import custom categories from CSV with gobierto_budgets_data format. Site domain is required"
    task :import_gobierto_budgets_data, [:site_domain, :csv_path] => :environment do |_t, args|

      csv_path = args[:csv_path]
      site_domain = args[:site_domain]
      unless File.file?(csv_path)
        puts "[ERROR] No CSV file found: #{csv_path}"
        exit(-1)
      end

      site = Site.find_by(domain: site_domain)

      unless site.present?
        puts "[ERROR] No site found for domain #{site_domain}"
        exit(-1)
      end

      csv_data = CSV.read(csv_path, col_sep: CsvUtils.detect_separator(csv_path), headers: true, header_converters: [lambda { |header| header.downcase }])
      importer = GobiertoBudgetsData::GobiertoBudgets::CustomCategoriesCsvImporter.new(csv_data, site: site)

      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems}"
    end

    desc "Import categories, providing the site_domain, the file path to the categories and the locale"
    task :import, [:site_domain, :file_path, :locale, :skip_existing] => [:environment] do |_t, args|
      def get_area_name(area)
        case area
        when 'E'
          GobiertoBudgets::EconomicArea.area_name
        when 'F'
          GobiertoBudgets::FunctionalArea.area_name
        when 'C'
          GobiertoBudgets::CustomArea.area_name
        end
      end

      def custom_name(row)
        row["Nombre"]
      end

      def custom_description(row)
        # Keep both column names for compatibility reasons
        row["Descripcion"] || row["Descripción"]
      end

      imported = 0
      skipped = 0
      existing_codes = {}

      skip_existing = args[:skip_existing] == "true"
      locale = args[:locale]
      I18n.locale = locale
      site = Site.find_by!(domain: args[:site_domain])

      CSV.foreach(args[:file_path], headers: true) do |row|
        area_name = get_area_name(row["Area"])
        code = row["Codigo"]
        kind = row["Tipo"]

        if skip_existing
          if existing_codes[area_name].blank?
            area_klass = GobiertoBudgets::BudgetArea.klass_for(area_name)
            existing_codes[area_name] = area_klass.all_descriptions.dig(locale.to_sym, area_name, kind) || {}
          end
          if existing_codes[area_name].key?(code)
            skipped += 1
            next
          end
        end

        c = GobiertoBudgets::Category.find_or_create_by!(site:, area_name:, kind:, code:)
        c.custom_name = custom_name(row)
        c.custom_description = custom_description(row)
        c.save!
        imported += 1
      end

      puts "[SUCCESS] Imported #{imported}, skipped #{skipped}"
    end
  end
end
