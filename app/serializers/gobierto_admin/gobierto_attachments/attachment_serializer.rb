module GobiertoAdmin
  module GobiertoAttachments
    class AttachmentSerializer < ActiveModel::Serializer
      attributes(
        :id,
        :site_id,
        :name,
        :description,
        :file_name,
        :file_digest,
        :url,
        :file_size,
        :current_version
      )
    end
  end
end
