# frozen_string_literal: true

class GobiertoPeople::ContentBlockRecordSerializer < ActiveModel::Serializer
  attributes :id, :title, :payload

  def id
    object.content_block.internal_id
  end

  def title
    object.content_block.title
  end
end
