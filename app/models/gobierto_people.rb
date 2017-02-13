module GobiertoPeople
  def self.table_name_prefix
    'gp_'
  end

  def self.searchable_models
    [ GobiertoPeople::Person, GobiertoPeople::PersonPost, GobiertoPeople::PersonEvent, GobiertoPeople::PersonStatement ]
  end
end
