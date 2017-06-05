require 'test_helper'

module GobiertoAttachments
  class AttachmentTest < ActiveSupport::TestCase

    def site
      @site ||= sites(:madrid)
    end

    def pdf_attachment
      @pdf_attachment ||= gobierto_attachments_attachments(:pdf_attachment)
    end

    def xlsx_attachment
      @xlsx_attachment ||= gobierto_attachments_attachments(:xlsx_attachment)
    end

    def attachment
      @attachment ||= gobierto_attachments_attachments(:attachment)
    end

    def txt_pdf_attachment
      @txt_pdf_attachment ||= gobierto_attachments_attachments(:txt_pdf_attachment)
    end

    def pdf_file
      @file ||= file_fixture('gobierto_attachments/attachment/pdf-attachment.pdf')
    end

    def xlsx_file
      @xlsx ||= file_fixture('gobierto_attachments/attachment/xlsx-attachment.xlsx')
    end

    def txt_pdf_file
      @txt_pdf_file ||= file_fixture('gobierto_attachments/attachment/txt-pdf-attachment.txt.pdf')
    end

    def file_digest(file)
      Attachment.file_digest(file)
    end

    def test_valid
      assert attachment.valid?
    end

    def test_create_attachment
      ::GobiertoAdmin::FileUploadService.any_instance.stubs(:call).returns('http://host.com/attachments/pdf-attachment.pdf')

      new_attachment = Attachment.create(
        site: site,
        name: 'New attachment name',
        description: 'New attachment description',
        file: pdf_file
      )

      assert new_attachment.valid?

      assert_equal 'New attachment name', new_attachment.name
      assert_equal 'New attachment description', new_attachment.description
      assert_equal 'pdf-attachment.pdf', new_attachment.file_name
      assert_equal file_digest(pdf_file), new_attachment.file_digest
      assert_equal 'http://host.com/attachments/pdf-attachment.pdf', new_attachment.url
      assert_equal 10022, new_attachment.file_size

      assert_equal 1, new_attachment.current_version
      assert_equal 1, new_attachment.versions.size
    end

    def test_update_attachment
      ::GobiertoAdmin::FileUploadService.any_instance.stubs(:call).returns('http://host.com/attachments/xlsx-attachment.xlsx')

      pdf_attachment.update_attributes!(
        name: '(EDITED) PDF Attachment Name',
        description: '(EDITED) Description of a PDF attachment',
        file: xlsx_file
      )

      assert pdf_attachment.valid?

      assert_equal 2, pdf_attachment.current_version
      assert_equal 2, pdf_attachment.versions.size

      assert_equal '(EDITED) PDF Attachment Name', pdf_attachment.name
      assert_equal '(EDITED) Description of a PDF attachment', pdf_attachment.description
      assert_equal 'xlsx-attachment.xlsx', pdf_attachment.file_name
      assert_equal file_digest(xlsx_file), pdf_attachment.file_digest
      assert_equal 'http://host.com/attachments/xlsx-attachment.xlsx', pdf_attachment.url
      assert_equal 3604, pdf_attachment.file_size
    end

    def test_update_attachment_file
      ::GobiertoAdmin::FileUploadService.any_instance.stubs(:call).returns('http://host.com/attachments/txt-pdf-attachment.txt.pdf')

      pdf_attachment.update_attributes!(file: txt_pdf_file)

      assert_equal 2, pdf_attachment.current_version
      assert_equal 2, pdf_attachment.versions.size

      assert_equal 'txt-pdf-attachment.txt.pdf', pdf_attachment.file_name
      assert_equal 10312, pdf_attachment.file_size
    end

    def test_update_attachment_metadata
      pdf_attachment.update_attributes!(name: '(SECOND EDIT) PDF Attachment Name')

      assert_equal 1, pdf_attachment.current_version
      assert_equal 1, pdf_attachment.versions.size

      assert_equal '(SECOND EDIT) PDF Attachment Name', pdf_attachment.name
    end

    def test_destroy_attachment
      pdf_attachment.destroy

      assert_raises ActiveRecord::RecordNotFound do
        GobiertoAttachments::Attachment.find(pdf_attachment.id)
      end

      last_version = PaperTrail::Version.where(item_id: pdf_attachment.id).last

      assert 'destroy', last_version.event
    end

    def test_attachment_extension
      assert_equal 'pdf',  pdf_attachment.extension
      assert_equal 'xlsx', xlsx_attachment.extension
      assert_equal '',     attachment.extension
      assert_equal 'pdf',  txt_pdf_attachment.extension
    end

  end
end
