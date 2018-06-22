module GobiertoPeople
  module SubmodulesHelper

    def enable_submodule(site, submodule_name)
      settings = site.gobierto_people_settings
      unless settings.settings["submodules_enabled"].include?(submodule_name.to_s)
        settings.settings["submodules_enabled"] << submodule_name.to_s
        settings.save!
      end
    end

    def disable_submodule(site, submodule_name)
      settings = site.gobierto_people_settings
      unless settings.settings["submodules_enabled"].exclude?(submodule_name.to_s)
        settings.settings["submodules_enabled"].reject! { |submodule| submodule == submodule_name.to_s }
        settings.save!
      end
    end

  end
end
