class GobiertoCalendars::EventSerializer < ActiveModel::Serializer
  attributes :id, :creator_id, :creator_name, :title, :description, :starts_at, :ends_at, :created_at, :updated_at

  has_many :locations
  has_many :attendees

  def creator_name
    object.collection.container.try(:name)
  end

  def creator_id
    object.collection.container.try(:id)
  end
end
