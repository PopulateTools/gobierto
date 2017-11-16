# frozen_string_literal: true

module GobiertoAdmin
  class FileAttachmentForm
    include ActiveModel::Model
    prepend ::GobiertoCommon::Trackable

    attr_accessor(
      :id,
      :site_id,
      :collection_id,
      :file,
      :description,
      :slug
    )

    attr_writer(
      :admin_id,
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
    validate :file_is_not_duplicated, if: -> { file.present? }
    validate :file_size_within_range, if: -> { file.present? }

    trackable_on :file_attachment

    notify_changed :name

    def initialize(attributes)
      attributes = attributes.to_h.with_indifferent_access
      super(attributes.except(:name))
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
      @file_attachment ||= file_attachment_class.find_by(id: id).presence || build_file_attachment
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
          persisted_attachment = file_attachment_class.find(id) # don't access memoized version, since its digest may already be updated
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
        file_attachment_attributes.collection      = collection if collection_id
        file_attachment_attributes.site            = site
        file_attachment_attributes.admin_id        = admin_id
        file_attachment_attributes.name            = name
        file_attachment_attributes.description     = description
        file_attachment_attributes.slug            = slug
        file_attachment_attributes.url             = url
        file_attachment_attributes.file_name       = file_name
        file_attachment_attributes.file_size       = file_size
        file_attachment_attributes.file_digest     = file_digest
        file_attachment_attributes.current_version = current_version
      end

      if @file_attachment.valid?
        run_callbacks(:save) do
          @file_attachment.save
        end

        @file_attachment
      else
        promote_errors(@file_attachment.errors)

        false
      end
    end

    def collection
      @collection ||= collection_class.find_by(id: collection_id) if collection_id
    end

    def upload_file
      FileUploadService.new(
        site: site,
        collection: file_attachment.model_name.collection,
        attribute_name: :file,
        file: file
      ).call
    end

    def file_is_not_duplicated
      attachment_hit = site.attachments.find_by(file_digest: file_attachment_class.file_digest(file))

      if attachment_hit.present? && ( !persisted? || (persisted? && id != attachment_hit.id) )
        errors.add(:file_digest,
          I18n.t('errors.messages.already_uploaded_html', url: admin_edit_attachment_path(attachment_hit))
        )
      end
    end

    def file_size_within_range
      max_size = file_attachment_class::MAX_FILE_SIZE_IN_BYTES

      if file.size > max_size
        errors.add(:file_size, "#{I18n.t('activerecord.messages.gobierto_attachments/attachment.file_too_big')} (#{file_attachment_class::MAX_FILE_SIZE_IN_MBYTES} Mb)")
      end
    end

    def admin_edit_attachment_path(attachment)
      if c = attachment.collection
        url_helpers.edit_admin_attachments_file_attachment_path(attachment, collection_id: c.id)
      else
        url_helpers.edit_admin_attachments_file_attachment_path(attachment)
      end
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

    protected

    def promote_errors(errors_hash)
      errors_hash.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
