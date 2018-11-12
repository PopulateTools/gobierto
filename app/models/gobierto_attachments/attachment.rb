# frozen_string_literal: true

require_dependency 'gobierto_attachments'

module GobiertoAttachments
  class Attachment < ApplicationRecord
    acts_as_paranoid column: :archived_at

    paginates_per 8

    attr_accessor :admin_id

    include ActsAsParanoidAliases
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Collectionable

    MAX_FILE_SIZE_IN_MBYTES = 50
    MAX_FILE_SIZE_IN_BYTES  = MAX_FILE_SIZE_IN_MBYTES.megabytes

    default_scope { order(id: :desc) }

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

    validates :site, :url, presence: true
    validates :slug, uniqueness: { scope: :site_id }
    # This validation is duplicated in FileAttachmentForm, but since it's still being used
    # from the API, we can't remove it.
    validates :file_digest, uniqueness: {
      scope: :site_id,
      message: ->(object, data) do
        url = object.site.attachments.find_by!(file_digest: object.file_digest).url
        "#{I18n.t('activerecord.messages.gobierto_attachments/attachment.already_uploaded')} #{url})."
      end
    }

    belongs_to :site

    after_create :add_item_to_collection
    before_validation :update_file_attributes
    after_restore :set_slug
    belongs_to :collection, class_name: "GobiertoCommon::Collection"

    has_many :collection_items, class_name: "GobiertoCommon::CollectionItem", as: :item

    scope :inverse_sorted, -> { order(id: :asc) }
    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_updated_at, ->{ order(updated_at: :desc) }

    def content_type
      MIME::Types.type_for(url).first.content_type
    end

    def self.extension_fontawesome_matching
      { "doc": "word", "docx": "word",
        "xls": "excel", "xlsx": "excel",
        "ppt": "powerpoint", "pptx": "powerpoint",
        "zip": "zip", "gzip": "zip", "tar": "zip",
        "pdf": "pdf",
        "jpg": "image", "gif": "image", "bmp": "image", "jpeg": "image", "png": "image",
        "avi": "video", "mp4": "video", "wmv": "video", "mpg": "video", "mov": "video" }
    end

    # Assumes file is opened and closed outside this function, since calling 'close'
    # here may delete the Tempfile
    def self.file_digest(file)
      file.rewind # just in case upper context left the read pointer at the end
      digest = Digest::MD5.hexdigest(file.read)
      file.rewind
      digest
    end

    def extension
      File.extname(file_name).tr('.', '')
    end

    def active?
      true
    end

    def created_at
      versions.last.created_at if versions.length.positive?
    end

    def parameterize
      { id: id }
    end

    def attributes_for_slug
      [name]
    end

    def human_readable_path
      url_helpers.gobierto_attachments_attachment_path(id: id)
    end

    def human_readable_url
      url_helpers.gobierto_attachments_attachment_url(id: id, host: site.domain)
    end

    def add_item_to_collection
      collection&.append(self)
    end

    def public?
      container.try(:reload).try(:public?) != false
    end

    private

    # This method is error-prone and should be REMOVED.
    # This logic is duplicated in FileAttachmentForm. The reason why version is not incremented
    # twice is because the Form Object decomposes file attribute in file_name, file_size, etc.,
    # so this code is not executed.
    def update_file_attributes
      if file
        if file.size > MAX_FILE_SIZE_IN_BYTES
          errors.add(:base, "#{I18n.t('activerecord.messages.gobierto_attachments/attachment.file_too_big')} (#{MAX_FILE_SIZE_IN_MBYTES} Mb)")
          throw :abort
        end

        self.file_digest = self.class.file_digest(file)

        if file_digest_changed? && unique_file_digest?
          self.file_name = file.original_filename
          self.file_size = file.size
          self.current_version += 1
          self.url = ::GobiertoAdmin::FileUploadService.new(site: site, collection: 'attachments', attribute_name: :attachment, file: file).call
        end
      end
    end

    def unique_file_digest?
      attachment_with_same_digest_id = site.attachments.where(file_digest: file_digest).pluck(:id).first
      attachment_with_same_digest_id.nil? || (attachment_with_same_digest_id == id)
    end

    def singular_route_key
      :gobierto_attachments_document
    end

  end
end
