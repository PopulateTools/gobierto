module GobiertoPeople
  def self.table_name_prefix
    "gp_"
  end

  def self.searchable_models
    [ GobiertoPeople::Person, GobiertoPeople::PersonPost, GobiertoPeople::PersonStatement ]
  end

  def self.module_submodules
    %w(officials agendas blogs statements departments interest_groups trips gifts invitations)
  end

  def self.remote_calendar_integrations
    %w( ibm_notes google_calendar microsoft_exchange )
  end
end
