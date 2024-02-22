# frozen_string_literal: true

module GobiertoAdmin
  class FileAttachmentForm < BaseForm

    attr_accessor(
      :id,
      :site_id,
      :collection_id,
      :description,
      :slug
    )

    attr_writer(
      :admin_id,
      :file,
      :file_name,
      :file_size,
      :file_digest,
      :url,
      :current_version
    )

    attr_reader :name

    delegate :persisted?, to: :file_attachment

    validates :file, presence: true, unless: :persisted?
    validates :site, presence: true
    validate :file_size_within_range, if: -> { file.present? }
    validates :collection, presence: true

    def initialize(attributes)
      attributes = attributes.to_h.with_indifferent_access
      super(attributes.except(:name, :archived_at))
      @name = attributes[:name].presence || (file ? file.original_filename : file_attachment.file_name)
    end

    def save
      save_file_attachment if valid?
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def admin_id
      @admin_id ||= file_attachment.admin_id
    end

    def file_attachment
      @file_attachment ||= file_attachment_class.find_by(id: id).presence ||
                           file && file_attachment_class.find_by(collection: collection, file_digest: file_digest).presence ||
                           build_file_attachment
    end
    alias content_context file_attachment

    def url
      # will upload just once, since its memoized
      @url ||= file ? upload_file : file_attachment.url
    end

    def file_name
      @file_name ||= file ? file.original_filename : file_attachment.file_name
    end

    def file_size
      @file_size ||= file ? file.size : file_attachment.file_size
    end

    def file_digest
      @file_digest ||= file ? file_attachment_class.file_digest(file) : file_attachment.file_digest
    end

    def current_version
      @current_version ||= begin
        if persisted?
          persisted_attachment = file_attachment_class.find(file_attachment.id) # don't access memoized version, since its digest may already be updated
          if persisted_attachment.file_digest != file_digest
            persisted_attachment.current_version + 1
          else
            persisted_attachment.current_version
          end
        else
          1
        end
      end
    end

    def file
      if @file.is_a?(String)
        tmp_file = Tempfile.new("attachment_file")
        tmp_file.binmode
        tmp_file.write(Base64.strict_decode64(@file))
        tmp_file.rewind
        # Mass assignment of file_name attribute is not permitted, it must always come from
        # an UploadedFile instance. Thus, we read it from params instead of attachment_params.
        @file = ActionDispatch::Http::UploadedFile.new(filename: file_name, tempfile: tmp_file)
      end
      @file
    end

    private

    def build_file_attachment
      file_attachment_class.new(site_id: site_id)
    end

    def file_attachment_class
      ::GobiertoAttachments::Attachment
    end

    def collection_class
      ::GobiertoCommon::Collection
    end

    def save_file_attachment
      @file_attachment = file_attachment.tap do |file_attachment_attributes|
        file_attachment_attributes.collection = collection
        file_attachment_attributes.site = site
        file_attachment_attributes.admin_id = admin_id
        file_attachment_attributes.name = name
        file_attachment_attributes.description = description
        file_attachment_attributes.slug = slug
        file_attachment_attributes.url = url
        file_attachment_attributes.file_name = file_name
        file_attachment_attributes.file_size = file_size
        file_attachment_attributes.file_digest = file_digest
        file_attachment_attributes.current_version = current_version
      end

      if @file_attachment.valid?
        @file_attachment.save

        @file_attachment
      else
        promote_errors(@file_attachment.errors)

        false
      end
    end

    def collection
      @collection ||= collection_class.find_by(id: collection_id)
    end

    def upload_file
      ::GobiertoCommon::FileUploadService.new(
        site: site,
        collection: file_attachment.model_name.collection,
        attribute_name: :file,
        file: file
      ).upload!
    end

    def file_size_within_range
      max_size = file_attachment_class::MAX_FILE_SIZE_IN_BYTES

      if file.size > max_size
        errors.add(:file_size, "#{I18n.t("activerecord.messages.gobierto_attachments/attachment.file_too_big")} (#{file_attachment_class::MAX_FILE_SIZE_IN_MBYTES} Mb)")
      end
    end

    def admin_edit_attachment_path(attachment)
      url_helpers.edit_admin_attachments_file_attachment_path(attachment, collection_id: attachment.collection.id)
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

  end
end
