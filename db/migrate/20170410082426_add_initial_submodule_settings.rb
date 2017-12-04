# frozen_string_literal: true

class AddInitialSubmoduleSettings < ActiveRecord::Migration[5.0]
  def up
    Site.all.each do |site|
      next unless site.configuration.gobierto_people_enabled?
      GobiertoPeople::Setting.create site: site, key: "agendas_submodule_active", value: "true"
      GobiertoPeople::Setting.create site: site, key: "officials_submodule_active", value: "true"
      GobiertoPeople::Setting.create site: site, key: "blogs_submodule_active", value: "true"
      GobiertoPeople::Setting.create site: site, key: "statements_submodule_active", value: "true"
    end
  end

  def down
    GobiertoPeople::Setting.where("key ~* ?", ".*_submodule_active").destroy_all
  end
end
