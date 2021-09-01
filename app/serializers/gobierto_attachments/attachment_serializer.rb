# frozen_string_literal: true

module GobiertoAttachments
  class AttachmentSerializer < ActiveModel::Serializer
    attributes(
      :name,
      :description,
      :file_name,
      :file_digest,
      :url,
      :human_readable_url,
      :human_readable_path,
      :file_size,
      :current_version,
      :created_at,
      :updated_at
    )
  end
end
