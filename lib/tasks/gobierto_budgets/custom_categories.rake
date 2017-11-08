# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :custom_categories do
    desc "Import categories"
    task :import, [:site_domain, :file_path] => [:environment] do |_t, args|
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

      # TODO: import data in different locales
      def custom_name(row)
        row["Nombre"]
      end

      def custom_description(row)
        row["Descripción"]
      end

      site = Site.find_by!(domain: args[:site_domain])
      ine_code = site.place.id

      I18n.locale = 'ca'
      CSV.foreach(args[:file_path], headers: true) do |row|
        c = GobiertoBudgets::Category.find_or_create_by! site: site, area_name: area_name(row['Area']), kind: row['Tipo'], code: row['Codigo']
        c.custom_name = custom_name(row)
        c.custom_description = custom_description(row)
        c.save!
      end
    end
  end
end
