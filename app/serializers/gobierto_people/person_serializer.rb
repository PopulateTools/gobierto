module GobiertoPeople
  class PersonSerializer < ActiveModel::Serializer

    attributes :name, :charge

  end
end
