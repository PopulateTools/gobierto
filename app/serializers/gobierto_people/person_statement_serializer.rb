# frozen_string_literal: true

class GobiertoPeople::PersonStatementSerializer < ActiveModel::Serializer
  attributes :id, :person_id, :person_name, :title, :published_on, :attachment_url, :attachment_size, :created_at, :updated_at

  has_many :content_block_records

  def person_name
    object.person.try(:name)
  end
end
