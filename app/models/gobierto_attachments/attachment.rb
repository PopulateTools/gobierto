require_dependency 'gobierto_attachments'

module GobiertoAttachments
  class Attachment < ApplicationRecord

    include GobiertoCommon::Searchable

    MAX_FILE_SIZE_IN_BYTES = 102400 # 100 Mb

    has_paper_trail(
      on:     [:create, :update, :destroy],
      ignore: [:name, :file_size, :file_name, :description, :current_version]
    )

    algoliasearch_gobierto do
      attribute :site_id, :name, :description, :file_name, :url, :file_size
      searchableAttributes ['name', 'description', 'file_name']
      attributesForFaceting [:site_id]
    end

    attr_accessor :file

    validates :site, :name, :file_size, :file_name, :file_digest, :url, :current_version, presence: true

    belongs_to :site

    before_validation :update_file_attributes

    def self.file_digest(file)
      Digest::MD5.hexdigest(file.read)
    end

    def extension
      File.extname(file_name).tr('.', '')
    end

    def active?
      true
    end

    private

    def update_file_attributes
      if file
        throw :abort if file.size > MAX_FILE_SIZE_IN_BYTES

        new_digest = Attachment.file_digest(file.open)

        if file_updated?(new_digest)
          self.url = ::GobiertoAdmin::FileUploadService.new(site: site, collection: 'attachments', attribute_name: :attachment, file: file).call
          self.file_name = file.original_filename
          self.file_size = file.size
          self.file_digest = new_digest
          self.current_version += 1
        end
        file.close
      end
    end

    def file_updated?(new_digest)
      file_digest.nil? || (file.present? && (new_digest != self.file_digest))
    end

  end
end
