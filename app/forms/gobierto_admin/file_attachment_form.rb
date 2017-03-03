module GobiertoAdmin
  class FileAttachmentForm
    include ActiveModel::Model

    attr_accessor(
      :site,
      :file,
      :collection
    )

    validates :file, presence: true
    validates :site, presence: true

    def save
      valid?
    end

    def file_url
      @file_url ||= FileUploadService.new(
        adapter: :s3,
        site: site,
        collection: collection,
        attribute_name: :attachment,
        file: file,
        content_disposition: "attachment"
      ).call
    end

    private

    def collection
      @collection ||= "file_attachments"
    end
  end
end
