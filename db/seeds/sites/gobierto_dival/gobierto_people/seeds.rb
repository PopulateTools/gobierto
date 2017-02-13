module GobiertoSeeds
  class Recipe
    def self.run(site)
      #
      # Content blocks
      #

      ## Official degrees block
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_official_degrees")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_official_degrees",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Títols oficials d'educació i formació", "es" => "Títulos oficiales de educación y formación" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "degree"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "degree",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Títol", "es" => "Título" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "center"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "center",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Center", "es" => "Centro" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "date"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "date",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["date"],
          label: { "ca" => "Data", "es" => "Fecha" }
        })
      end

      ## Unofficial degrees block
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_unofficial_degrees")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_unofficial_degrees",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Títols no oficials d'educació i formació", "es" => "Títulos no oficiales de educación y formación" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "degree"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "degree",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Títol", "es" => "Título" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "center"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "center",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Center", "es" => "Centro" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "date"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "date",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["date"],
          label: { "ca" => "Data", "es" => "Fecha" }
        })
      end

      ## Previous jobs
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_previous_jobs")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_previous_jobs",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Experiència laboral", "es" => "Experiencia laboral" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "organization"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "organization",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Organizació", "es" => "Organización" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "position"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "position",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Càrrec", "es" => "Cargo" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "begin_date"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "begin_date",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["date"],
          label: { "ca" => "Data inici", "es" => "Fecha inicio" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "end_date"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "end_date",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["date"],
          label: { "ca" => "Data fi", "es" => "Fecha final" }
        })
      end

      ## Languages
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_languages")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_languages",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Idiomes", "es" => "Idiomas" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "language"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "language",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Idioma", "es" => "Idioma" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "level_speaking"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "level_speaking",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Expressió oral - nivell", "es" => "Expresión oral - nivel" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "level_writing"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "level_writing",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Expressió escrita - nivell", "es" => "Expresión escrita - nivel" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "level_listening"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "level_listening",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Expressió lectura y compresió - nivell", "es" => "Expresión lectura y compresión - nivel" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "official_titles"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "official_titles",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Certificacions oficials", "es" => "Certificaciones oficiales" }
        })
      end

      ## Publications
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_publications")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_publications",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Publicacions", "es" => "Publicaciones" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "title"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "title",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Títol de la publicació", "es" => "Título de la publicación" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "editorial"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "editorial",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Editorial", "es" => "Editorial" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "date"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "date",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["date"],
          label: { "ca" => "Data", "es" => "Fecha" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "notes"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "notes",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Notes", "es" => "Notas" }
        })
      end

      ## Awards
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_awards")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_awards",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Premis i distincions", "es" => "Premios y distinciones" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "award"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "award",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Premi/distinció", "es" => "Premio/distinción" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "institution"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "institution",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Institució", "es" => "Institución" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "notes"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "notes",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Notes", "es" => "Notas" }
        })
      end

      ## Awards
      block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: "gobierto_people_groups")
      if block.nil?
        block = GobiertoCommon::ContentBlock.create!({
          internal_id: "gobierto_people_groups",
          site: site,
          content_model_name: "GobiertoPeople::Person",
          title: { "ca" => "Pertinença a grups/associacions", "es" => "Pertenencia a grupos/asociaciones" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "group"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "group",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Grup/Associació", "es" => "Grupo/Asociación" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "position"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "position",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Càrrec", "es" => "Cargo" }
        })
      end

      block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: "notes"
      if block_field.nil?
        GobiertoCommon::ContentBlockField.create!({content_block: block, name: "notes",
          field_type: ::GobiertoCommon::ContentBlockField.field_types["text"],
          label: { "ca" => "Notes", "es" => "Notas" }
        })
      end
    end
  end
end
