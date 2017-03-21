class GobiertoPeople::PersonEventLocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :lat, :lng
end
