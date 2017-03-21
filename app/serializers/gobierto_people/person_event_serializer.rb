class GobiertoPeople::PersonEventSerializer < ActiveModel::Serializer
  attributes :id, :person_id, :person_name, :title, :description, :starts_at, :ends_at, :attachment_url, :created_at, :updated_at

  has_many :locations
  has_many :attendees

  def person_name
    object.person.try(:name)
  end
end
