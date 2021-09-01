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
        :human_readable_url,
        :human_readable_path,
        :file_size,
        :current_version,
        :created_at
      )
    end
  end
end
