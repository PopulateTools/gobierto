# rails runner script/xblr/script.rb

# ------------------------------------------------------------------------------
# Utility functions
# ------------------------------------------------------------------------------

def budget_line_code_to_i(budget_line_code_s)
  return budget_line_code_s.to_i
rescue
  code_segments = budget_line_code_s.split('-')
  return (code_segments[0].to_i + code_segments[1].to_i)
end

def get_parent_budget_lines_codes_s(budget_line_code_s)
  parent_budget_line_codes = []
  budget_line_code_segments_s      = budget_line_code_s.split('-')
  first_budget_line_code_segment_s = budget_line_code_segments_s.first

  if first_budget_line_code_segment_s.length == 2
    parent_budget_line_codes << (first_budget_line_code_segment_s.to_i / 10).to_s
  elsif first_budget_line_code_segment_s.length == 3
    parent_budget_line_codes << first_budget_line_code_segment_s[0]
    parent_budget_line_codes << (first_budget_line_code_segment_s.to_i / 10).to_s
  end

  if budget_line_code_segments_s.length == 2
    parent_budget_line_codes << first_budget_line_code_segment_s
  end

  parent_budget_line_codes.delete("8") # ==> TODO: ñapa
  parent_budget_line_codes
end

def get_xblr_id_from_budget_line_name(budget_line_name)
  budget_line_name.parameterize.split('-').map { |word| word.capitalize }.join
end

def get_budget_line_kind(budget_line_key)
  budget_line_key_prefix = budget_line_key.split('_').first
  if budget_line_key_prefix["Gastos"]
    :gasto
  elsif budget_line_key_prefix["Ingresos"]
    :ingreso
  else
    :error
  end
end

def get_budget_line_area(budget_line_key)
  budget_line_key_prefix = budget_line_key.split('_').first
  if budget_line_key_prefix["Economica"]
    :economica
  elsif budget_line_key_prefix["Funcional"]
    :funcional
  else
    :error
  end
end

# ------------------------------------------------------------------------------
# Replacements hash
# ------------------------------------------------------------------------------

EXCEPTIONS = {
  "TransferenciasCorrientesEnCumplimientoDeConveniosSuscritosConLaComunidadAutonomaEnMateriaDeServiciosSocialesY" => "TransferenciasCorrientesEnCumplimientoDeConveniosSuscritosConLaComunidadAutonomaEnMateriaDeServiciosSocialesYPoliticasDeIgualdad"
}

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

puts "[START]"

file = File.open("script/xblr/AJ-TrimLoc-2016.xbrl") { |f| Nokogiri::XML(f) }

# ------------------------------------------------------------------------------
# Obtain all budget lines IDs as they appear in the XBLR file
# ------------------------------------------------------------------------------

xblr_contextRef_attributes = file.xpath("//@contextRef")
xblr_contextRef_values     = xblr_contextRef_attributes.map { |attribute| attribute.value }

# Filter only those who start by "IdContextos.*"
xblr_budget_lines_ids = {}
xblr_contextRef_values.map do |attribute|
  (attribute =~ /IdContextos.*/) ? xblr_budget_lines_ids.store(attribute, { used: false } ) : nil
end.compact.uniq

partidas_ingresos_area_economica = GobiertoBudgets::EconomicArea.all_items["I"]   # => 334 [ { "codigo" => "nombre" }]
partidas_gastos_area_economica   = GobiertoBudgets::EconomicArea.all_items["G"]   # => 391

partidas_gastos_area_economica["453"] = "A sociedades mercantiles, entidades públicas empresariales y otros organismos públicos dependientes de las Comunidades Autónomicas"
partidas_gastos_area_economica["753"] = "A sociedades mercantiles, entidades públicas empresariales y otros organismos públicos dependientes de las Comunidades Autónomicas"

# --- Partidas ingresos area economica ---

diccionario_partidas_ingresos_area_economica = {}

partidas_ingresos_area_economica.each do |key, value|
  diccionario_partidas_ingresos_area_economica.store(key, { name: value , search_name: "IdContextosEconomicaIngresos_" + get_xblr_id_from_budget_line_name(value) })
end

diccionario_partidas_ingresos_area_economica = diccionario_partidas_ingresos_area_economica.sort.to_h

# --- Partidas gastos area economica ---

diccionario_partidas_gastos_area_economica = {}

partidas_gastos_area_economica.each do |key, value|
  diccionario_partidas_gastos_area_economica.store(key, { name: value , search_name: "IdContextosEconomicaGastos_" + get_xblr_id_from_budget_line_name(value) })
end

diccionario_partidas_gastos_area_economica = diccionario_partidas_gastos_area_economica.sort.to_h

# ------------------------------------------------------------------------------
# Look for hits in XBLR file
# ------------------------------------------------------------------------------

def build_elastic_to_xblr_dictionary(elastic_budget_lines, xblr_budget_lines_ids)
  elastic_to_xblr_dictionary = {}

  elastic_budget_lines.each do |elastic_bl_code, elastic_bl_info|

    elastic_to_xblr_dictionary.store(elastic_bl_code, { bl_name_in_elastic: elastic_bl_info[:name], match: false })

    # Look for exact matches on XBLR file
    # --------------------------------------------------------------------------

    elastic_bl_id = elastic_bl_info[:search_name]

    if xblr_budget_lines_ids[elastic_bl_id]
      #raise Exception if xblr_budget_lines_ids[elastic_bl_id][:used]

      elastic_to_xblr_dictionary[elastic_bl_code].merge!(xblr_id: elastic_bl_id, match: true)
      xblr_budget_lines_ids[elastic_bl_id][:used] = true
      next
    end

    # Look for candidate partial matches, and store them
    # --------------------------------------------------------------------------

    elastic_bl_id_prefix = elastic_bl_id.split('_').first
    elastic_bl_id_suffix = elastic_bl_id.split('_').second

    regex_for_potential_matches = Regexp.new("^#{elastic_bl_id_prefix}.*#{elastic_bl_id_suffix}$")

    potential_matches = xblr_budget_lines_ids.keys.map do |xblr_id|
      (xblr_id =~ regex_for_potential_matches && !xblr_budget_lines_ids[xblr_id][:used]) ? xblr_id : nil
    end.compact.sort_by(&:length)

    elastic_to_xblr_dictionary[elastic_bl_code].merge!(potential_matches: potential_matches)

    # If just one potential match, assign it
    if potential_matches.size == 1
      selected_match = potential_matches.first

      elastic_to_xblr_dictionary[elastic_bl_code].merge!(match: true, guessed: true, guessed_match: selected_match, reason: 'Only one potential match')
      xblr_budget_lines_ids[selected_match][:used] = true
      next
    end

    # Filter potential matches using regex builded by looking at parent budget lines ids
    # --------------------------------------------------------------------------

    # Generate filter regex by looking at parent budget lines

    elastic_parent_bl_codes_s = get_parent_budget_lines_codes_s(elastic_bl_code)

    if elastic_parent_bl_codes_s.any?
      parent_bl_id_suffixes = ""

      elastic_parent_bl_codes_s.each do |parent_bl_code|
        if parent_bl_code.to_i > 0
          elastic_parent_bl_id = elastic_budget_lines[parent_bl_code][:search_name]
          elastic_parent_bl_id_suffix = elastic_parent_bl_id.split('_').last

          if replacement_string = EXCEPTIONS[elastic_parent_bl_id_suffix]
            parent_bl_id_suffixes << replacement_string
          elsif elastic_parent_bl_id_suffix == "TransferenciasCorrientes"
            unless elastic_parent_bl_codes_s.include?("47" || "45" || "42")
              parent_bl_id_suffixes << "(TransferenciaCorrientes|TransferenciasCorrientes)"
            end
          elsif elastic_parent_bl_id_suffix == "ASociedadesMercantilesEntidadesPublicasEmpresarialesYOtrosOrganismosPublicosDependientesDeLas"
            parent_bl_id_suffixes << "_ASociedadesMercantilesEntidadesPublicasEmpresarialesYOtrosOrganismosPublicosDependientesDeLasComunidadesAutonomicas"
          elsif elastic_parent_bl_id_suffix == "ASociedadesMercantilesEntidadesPublicasEmpresarialesYOtrosOrganismosPublicosDependientesDeLasComunidadesAutonomicas"
            parent_bl_id_suffixes << "_(#{elastic_parent_bl_id_suffix}|AEntesPublicosYSociedadesMercantilesDeLaEntidadLocal|ASociedadesMercantilesEntidadesPublicasEmpresarialesYOtrosOrganismosPublicosDependientesDeLasComunidadesAutonomas)"
          elsif elastic_parent_bl_id_suffix == "GastosEnBienesCorrientesYServicios"
            parent_bl_id_suffixes << "_(GastosEnBienesCorrientesYServicios|GastosCorrientesEnBienesYServicios)"
          elsif elastic_parent_bl_id_suffix == "TasasYOtrosIngresos" || elastic_parent_bl_id_suffix == "GastosDePersonal" || elastic_parent_bl_id_suffix == "GastosFinancieros"
            # do nothing
          else
            parent_bl_id_suffixes << "_#{elastic_parent_bl_id_suffix}"
          end

        end
      end

      # Filter potential matches using this regex

      filtered_potential_matches = potential_matches.map do |xblr_id|
        (xblr_id =~ Regexp.new(parent_bl_id_suffixes) && !xblr_budget_lines_ids[xblr_id][:used]) ? xblr_id : nil
      end.compact.sort_by(&:length)

      if filtered_potential_matches.size == 1
        selected_match = filtered_potential_matches.first

        elastic_to_xblr_dictionary[elastic_bl_code].merge!(match: true, guessed: true, guessed_match: selected_match, reason: 'Only one parent-filtered potential match')
        xblr_budget_lines_ids[selected_match][:used] = true
        next
      elsif filtered_potential_matches.size > 1
        elastic_to_xblr_dictionary[elastic_bl_code][:potential_matches] = potential_matches
      elsif filtered_potential_matches.empty?
        elastic_to_xblr_dictionary[elastic_bl_code][:parent_filtering_regex] = parent_bl_id_suffixes

        # Relax the regex filtering condition
        relaxed_parents_regex_filter = parent_bl_id_suffixes.split('_')
        relaxed_parents_regex_filter.shift(2)
        relaxed_parents_regex_filter = relaxed_parents_regex_filter.join('_')

        relaxed_parent_filtered_potential_matches = potential_matches.map do |xblr_id|
          (xblr_id =~ Regexp.new(".*#{relaxed_parents_regex_filter}.*") && !xblr_budget_lines_ids[xblr_id][:used]) ? xblr_id : nil
        end.compact

        if relaxed_parent_filtered_potential_matches.size == 1
          selected_match = relaxed_parent_filtered_potential_matches.first

          elastic_to_xblr_dictionary[elastic_bl_code].merge!(match: true, guessed: true, guessed_match: selected_match, reason: 'Only one relaxed parent-filtered potential match')
          xblr_budget_lines_ids[selected_match][:used] = true
          next
        elsif relaxed_parent_filtered_potential_matches.size > 1
          # If still more than one potential match, assign them
          elastic_to_xblr_dictionary[elastic_bl_code][:potential_matches] = relaxed_parent_filtered_potential_matches
        elsif relaxed_parent_filtered_potential_matches.empty?
          elastic_to_xblr_dictionary[elastic_bl_code][:relaxed_parent_filtering_regex] = relaxed_parents_regex_filter
        end
      end
    end

    # Gestionar ambigüedades de las partidas relacionadas con funcionario en prácticas
    # --------------------------------------------------------------------------

    id_partidas_func_si_practicas = elastic_to_xblr_dictionary[elastic_bl_code][:potential_matches].select { |m| m[/PersonalFuncionarioEnPracticas/] }

    if elastic_to_xblr_dictionary[elastic_bl_code][:potential_matches].size == 2 && id_partidas_func_si_practicas.size == 1
      id_partida_func_si_practicas = id_partidas_func_si_practicas.first
      id_partida_func_no_practicas = (elastic_to_xblr_dictionary[elastic_bl_code][:potential_matches] - id_partidas_func_si_practicas).first

      if elastic_parent_bl_codes_s.include?("120")
        selected_match = id_partida_func_no_practicas
      elsif elastic_parent_bl_codes_s.include?("124")
        selected_match = id_partida_func_si_practicas
      end

      if elastic_parent_bl_codes_s.include?("120") || elastic_parent_bl_codes_s.include?("124")
        elastic_to_xblr_dictionary[elastic_bl_code].merge!(match: true, guessed: true, guessed_match: selected_match, reason: 'One potential match. Ambigüedad Func. prácticas.')
        xblr_budget_lines_ids[selected_match][:used] = true
        next
      end
    end

    # Hacer otra pasada a ver si hay alguno con una única potential_match ==> Pero esta vez coger sólo las qu eno están ocupadas
  end

  elastic_to_xblr_dictionary
end


income_economic_area_elastic_to_xblr_dictionary  = build_elastic_to_xblr_dictionary(diccionario_partidas_ingresos_area_economica, xblr_budget_lines_ids)
expense_economic_area_elastic_to_xblr_dictionary = build_elastic_to_xblr_dictionary(diccionario_partidas_gastos_area_economica,   xblr_budget_lines_ids)

# ------------------------------------------------------------------------------
# Write results to JSON file
# ------------------------------------------------------------------------------

File.open("script/xblr/income_economic_area_budget_lines.json","w") do |f|
  f.write JSON.pretty_generate(income_economic_area_elastic_to_xblr_dictionary)
end

File.open("script/xblr/expense_economic_area_budget_lines.json","w") do |f|
  f.write JSON.pretty_generate(expense_economic_area_elastic_to_xblr_dictionary)
end

# ------------------------------------------------------------------------------
# Write dictionary to YAML file
# ------------------------------------------------------------------------------

xblr_to_elasticsearch_dictionary = {
  'metadata' => {
    'year' => 2016
  },
  'dictionary' => {}
}

# Insertamos todas las claves del XBLR, con valor a false

xblr_budget_lines_ids.each_key do |budget_line_id|
  xblr_to_elasticsearch_dictionary['dictionary'].store(budget_line_id, 'NOT-FOUND')
end

income_economic_area_elastic_to_xblr_dictionary.each do |key, value|
  xblr_id = value[:xblr_id] || value[:guessed_match]
  if xblr_id
    xblr_to_elasticsearch_dictionary['dictionary'].store(xblr_id, { 'code' => key, 'kind' => 'I', 'area' => 'economic' })
  end
end

expense_economic_area_elastic_to_xblr_dictionary.each do |key, value|
  xblr_id = value[:xblr_id] || value[:guessed_match]
  if xblr_id
    xblr_to_elasticsearch_dictionary['dictionary'].store(xblr_id, { 'code' => key, 'kind' => 'E', 'area' => 'economic' })
  end
end

File.open("script/xblr/xblr_ids_to_elasticsearch_dictionary.yml","w") do |file|
   file.write xblr_to_elasticsearch_dictionary.to_yaml
end

puts "[END]"
