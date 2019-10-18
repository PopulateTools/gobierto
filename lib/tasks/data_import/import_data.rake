# frozen_string_literal: true

namespace :data_import do
  namespace :import_data do

    ###############
    # mercamadrid #
    ###############

    DICTIONARY = {
      start_date: "Fecha Desde",
      end_date: "Fecha Hasta",
      variety_code: "Código Variedad",
      variety_description: "Descripción Variedad",
      origin: "Origen",
      origin_description: "Descripción Origen",
      kilograms: "Kilos",
      expected_price: "Precio Más Frecuente",
      maximum_price: "Precio Máximo",
      minimum_price: "Precio Mínimo",
      family: "Familia",
      national: "Nacional-Ext",
      category: "Categoría",
      product_name: "Producto"
    }

    TRANSFORMATIONS = {
      default: ->(value) { value },
      start_date: ->(value) { Date.parse(value) },
      end_date: ->(value) { Date.parse(value) },
      kilograms: ->(value) { value.to_i },
      expected_price: ->(value) { value.tr(",", ".").to_f },
      maximum_price: ->(value) { value.tr(",", ".").to_f },
      minimum_price: ->(value) { value.tr(",", ".").to_f },
      national: ->(value) { value == "España" }
    }

    ##################
    # taxi_flota_mad #
    ##################

    # DATE_PARSER = ->(value) { value.blank? ? nil : Date.strptime(value, "%m/%d/%Y") }
    # INTEGER_PARSER = ->(value) { value.to_i }
    # FLOAT_PARSER = ->(value) { value&.tr(",", ".")&.to_f }
    # BOOLEAN_PARSER = ->(value) { value == "SI" }

    # DICTIONARY = {
    #   codigo: "Código",
    #   matricula: "Matrícula",
    #   fecha_matriculacion: "Fecha Matriculación",
    #   marca: "Marca",
    #   modelo: "Modelo",
    #   tipo: "Tipo",
    #   variante: "Variante",
    #   clasificacion_medioambiental: "Clasificación medioambiental",
    #   combustible: "Combustible",
    #   cilindrada: "Cilindrada",
    #   potencia: "Potencia",
    #   numero_de_plazas: "Número de Plazas",
    #   fecha_inicio_de_prestacion_del_servicio_de_taxi: "Fecha inicio de prestación del servicio de taxi",
    #   eurotaxi: "Eurotaxi",
    #   regimen_especial_de_eurotaxi: "Régimen Especial de Eurotaxi",
    #   fecha_inicio_regimen_especial_eurotaxi: "Fecha inicio Régimen Especial Eurotaxi",
    #   fecha_fin_regimen_especial_eurotaxi: "Fecha fin Régimen Especial Eurotaxi",
    #   fecha: "Fecha",
    #   ano_matriculacion: "Año Matriculación",
    #   ano_mes_matriculacion: "Año-Mes Matriculación"
    # }

    # TRANSFORMATIONS = {
    #   default: ->(value) { value },
    #   fecha_matriculacion: DATE_PARSER,
    #   fecha_inicio_de_prestacion_del_servicio_de_taxi: DATE_PARSER,
    #   fecha_inicio_regimen_especial_eurotaxi: DATE_PARSER,
    #   fecha_fin_regimen_especial_eurotaxi: DATE_PARSER,
    #   fecha: DATE_PARSER,
    #   codigo: INTEGER_PARSER,
    #   cilindrada: INTEGER_PARSER,
    #   ano_matriculacion: INTEGER_PARSER,
    #   potencia: FLOAT_PARSER,
    #   eurotaxi: BOOLEAN_PARSER,
    #   regimen_especial_de_eurotaxi: BOOLEAN_PARSER
    # }

    # Example: rake data_import:import_data:import[/Users/edu/assets_dumps/automatic_summary/mercamad.csv]
    # Example: rake data_import:import_data:import[/Users/edu/assets_dumps/automatic_summary/taxi_flota_mad.csv]
    desc "Import records from csv"
    task :import, [:file_path] => [:environment] do |_t, args|
      file_name = args[:file_path]

      data = CSV.read(file_name, headers: true)

      ImportedRecord.destroy_all

      data.each do |record|
        ImportedRecord.create(
          DICTIONARY.inject({}) do |attributes, (dest_key, orig_key)|
            attributes.update(
              dest_key => calculate_value(dest_key, record[orig_key])
            )
          end
        )
      end

      # Record example:
      # {
      #   "Fecha Desde":"20190101"
      #   "Fecha Hasta":"20190131"
      #   "Código Variedad":"CA 0101"
      #   "Descripción Variedad":"VACUNO CANAL"
      #   "Origen":"6"
      #   "Descripción Origen":"BADAJOZ"
      #   "Kilos":"10000"
      #   "Precio Más Frecuente":"4,25"
      #   "Precio Máximo":"4,25"
      #   "Precio Mínimo":"4,25"
      #   "Familia":"CA"
      #   "Nacional-Ext":"España"
      #   "Categoría":"Carne"
      #   "Producto":"VACUNO"
      # }

      puts "==================="
      puts " - Imported file #{file_name}"
      puts "==================="
    end

    def calculate_value(key, raw_value)
      transform_proc = TRANSFORMATIONS.fetch(key) { TRANSFORMATIONS[:default] }
      transform_proc.call(raw_value)
    end
  end
end
