class GobiertoPeople::ContentBlockRecordSerializer < ActiveModel::Serializer
  attributes :name, :payload

  def name
    object.content_block.internal_id
  end
end
