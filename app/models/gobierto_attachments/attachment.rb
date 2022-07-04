# frozen_string_literal: true

module GobiertoAttachments
  class Attachment < ApplicationRecord
    acts_as_paranoid column: :archived_at

    paginates_per 20

    attr_accessor :admin_id

    include ActsAsParanoidAliases
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Collectionable

    MAX_FILE_SIZE_IN_MBYTES = 50
    MAX_FILE_SIZE_IN_BYTES = MAX_FILE_SIZE_IN_MBYTES.megabytes

    default_scope { order(id: :desc) }

    has_paper_trail(
      on: [:create, :update, :destroy],
      ignore: [:name, :file_size, :file_name, :description, :current_version]
    )

    multisearchable(
      against: [:name, :description, :file_name],
      additional_attributes: lambda { |item|
        {
          site_id: item.site_id,
          title_translations: item.truncated_translations(:name),
          description_translations: item.truncated_translations(:description),
          resource_path: item.human_readable_url,
          searchable_updated_at: item.updated_at,
          meta: {
            url: item.url,
            file_size: item.file_size
          }
        }
      },
      if: :searchable?
    )

    attr_accessor :file

    validates :site, :url, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    belongs_to :site

    after_create :add_item_to_collection
    after_restore :set_slug

    has_many :collection_items, class_name: "GobiertoCommon::CollectionItem", as: :item

    scope :inverse_sorted, -> { order(id: :asc) }
    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }

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
      File.extname(file_name).tr(".", "")
    end

    def active?
      !archived?
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

    def singular_route_key
      :gobierto_attachments_document
    end
  end
end
