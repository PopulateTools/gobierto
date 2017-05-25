# frozen_string_literal: true

class GobiertoPeople::PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :position, :bio, :bio_url, :avatar_url, :category, :political_group, :party, :created_at, :updated_at

  has_many :content_block_records

  def political_group
    object.political_group.try(:name)
  end

  def position
    object.charge
  end
end
