# frozen_string_literal: true

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

      importer = GobiertoBudgetsData::GobiertoBudgets::CustomCategoriesCsvImporter.new(CSV.read(csv_path, headers: true), site: site)

      nitems = importer.import!
      puts "[SUCCESS] Imported #{nitems}"
    end

    desc "Import categories, providing the site_domain, the file path to the categories and the locale"
    task :import, [:site_domain, :file_path, :locale] => [:environment] do |_t, args|
      def area_name(area)
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

      I18n.locale = args[:locale]
      site = Site.find_by!(domain: args[:site_domain])

      CSV.foreach(args[:file_path], headers: true) do |row|
        c = GobiertoBudgets::Category.find_or_create_by! site: site, area_name: area_name(row['Area']), kind: row['Tipo'], code: row['Codigo']
        c.custom_name = custom_name(row)
        c.custom_description = custom_description(row)
        c.save!
      end
    end
  end
end
