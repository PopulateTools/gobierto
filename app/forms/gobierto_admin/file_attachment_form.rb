require "file_uploader/s3"

module GobiertoAdmin
  class FileAttachmentForm
    include ActiveModel::Model

    attr_accessor(
      :file,
      :base_path
    )

    validates :file, presence: true

    def save
      valid?
    end

    def file_url
      @file_url ||= FileUploader::S3.new(
        file: file,
        file_name: "#{base_path}/attachment-#{SecureRandom.uuid}"
      ).call
    end

    private

    def base_path
      @base_path ||= "file_attachments"
    end
  end
end
