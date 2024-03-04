# frozen_string_literal: true

require "marcel"

module GobiertoCommon
  class PlainCustomFieldValueDecorator < BaseDecorator
    class TermNotFound < StandardError; end

    include GobiertoHelper

    attr_accessor :plain_text_value

    attr_writer :allow_vocabulary_terms_creation

    def initialize(custom_field)
      @object = custom_field
    end

    def allow_vocabulary_terms_creation?
      @allow_vocabulary_terms_creation ||= false
    end

    def value
      return unless plain_text_value

      if has_localized_value?
        localized_value
      elsif has_vocabulary?
        vocabulary_value
      elsif has_options?
        options_value
      elsif image?
        image_value
      else
        plain_text_value
      end
    end

    private

    def find_term(term_text)
      return if term_text.blank?

      vocabulary.terms.with_name_translation(term_text).take ||
        allow_vocabulary_terms_creation? && vocabulary.terms.create(name: term_text) ||
        raise(TermNotFound, { term: term_text, vocabulary: vocabulary.name, uid: uid }.to_json)
    end

    def localized_value
      return unless has_localized_value?

      locale_key = site.configuration.default_locale || I18n.locale || I18n.default_locale
      { locale_key.to_s => plain_text_value }
    end

    def vocabulary_value
      return unless has_vocabulary?

      if vocabulary_multiple_values?
        splitted_plain_text_value.map do |term|
          find_term(term)&.id
        end.compact.map(&:to_s)
      else
        find_term(plain_text_value.strip)&.id.to_s
      end
    end

    def options_value
      return unless has_options?

      selections = multiple_options? ? splitted_plain_text_value : [plain_text_value.strip]

      values = selections.map do |selection|
        options.find do |_key, translations|
          translations.values.include? selection
        end
      end.compact.map(&:first)
      return values if multiple_options?

      values&.first
    end

    def images_data
      images_sources = Nokogiri::HTML(markdown(plain_text_value)).css("img").map { |image| { src: image["src"], alt: image["alt"] } }

      images_sources = images_sources.first(1) unless multiple?

      images_data = images_sources.map do |image_data|
        download_data = download_file(image_data[:src])

        next if download_data.blank?

        next unless download_data[:mime_type].starts_with?("image/")

        image_data.merge(download_data)
      end.compact
    end

    def image_value
      attachments_urls = images_data.map do |image_data|
        url = ::GobiertoCommon::FileUploadService.new(
          site: site,
          collection: model_name.collection,
          attribute_name: uid,
          file: image_data[:file]
        ).upload!

        name = image_data[:alt] || image_data[:file_name]

        file_attachment = file_attachment_class.new(
          image_data.slice(:file_name, :file_size, :file_digest).merge(
            collection: attachments_collection,
            site: site,
            name: name,
            url: url,
            current_version: 1
          )
        )

        next url if file_attachment.save
      end.compact

      multiple? ? attachments_urls : attachments_urls.first
    end

    def download_file(url)
      uri = URI.parse(url)
      file_name = File.basename(uri.path)

      return unless uri.respond_to?(:open)

      content = uri.open

      tmp_file = Tempfile.new
      tmp_file.binmode
      tmp_file.write(content.binmode.read)
      tmp_file.close
      {
        file: ActionDispatch::Http::UploadedFile.new(filename: file_name, tempfile: tmp_file, original_filename: file_name),
        file_name:,
        mime_type: Marcel::MimeType.for(content),
        file_size: content.size,
        file_digest: file_attachment_class.file_digest(content)
      }
    rescue URI::InvalidURIError, OpenURI::HTTPError => e
      nil
    rescue StandardError => e
      nil
    end

    def vocabulary_multiple_values?
      return unless configuration

      configuration.vocabulary_type != "single_select"
    end

    def file_attachment_class
      ::GobiertoAttachments::Attachment
    end

    def splitted_plain_text_value
      (CSV.parse_line(plain_text_value.tr("\n", ",").gsub(/\"\s*,\s*\"/, "\",\"").strip, liberal_parsing: true) || []).compact.map(&:strip)
    rescue CSV::MalformedCSVError
      plain_text_value.tr("\n", ",").split(",").compact.map(&:strip)
    end

    def attachments_collection
      @attachments_collection ||= site.collections.find_by(container: site, item_type: "GobiertoAttachments::Attachment")
    end
  end
end
