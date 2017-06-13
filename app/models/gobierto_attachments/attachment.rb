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

    validates :file_digest, uniqueness: {
      scope: :site_id,
      message: ->(object, data) do
        url = object.site.attachments.find_by!(file_digest: object.file_digest).url
        "not unique (already uploaded at #{url})."
      end
    }

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
        if file.size > MAX_FILE_SIZE_IN_BYTES
          errors.add(:base, "File exceeds max size")
          throw :abort
        end

        self.file_digest = self.class.file_digest(file.open)

        if file_digest_changed? && unique_file_digest?
          self.file_name = file.original_filename
          self.file_size = file.size
          self.current_version += 1
          self.url = ::GobiertoAdmin::FileUploadService.new(site: site, collection: 'attachments', attribute_name: :attachment, file: file).call
        end

        file.close
      end
    end

    def unique_file_digest?
      attachment_with_same_digest_id = site.attachments.where(file_digest: file_digest).pluck(:id).first
      attachment_with_same_digest_id.nil? || (attachment_with_same_digest_id == id)
    end

  end
end
