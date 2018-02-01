# frozen_string_literal: true

module GobiertoAttachments::AttachableTest
  def pdf_attachment
    @pdf_attachment ||= gobierto_attachments_attachments(:pdf_attachment)
  end

  def xlsx_attachment
    @xlsx_attachment ||= gobierto_attachments_attachments(:xlsx_attachment)
  end

  def attachables
    [attachable_without_attachment, attachable_with_attachment]
  end

  def test_link_attachment
    attachables.each { |attachable| attachable.link_attachment(pdf_attachment) }

    assert_equal 1, attachable_without_attachment.attachments.size
    assert_equal 2, attachable_with_attachment.attachments.size

    assert_equal "http://host.com/attachments/super-long-and-ugly-aws-id/pdf-attachment.pdf", attachable_without_attachment.attachments.first.url
    assert_equal "http://host.com/attachments/super-long-and-ugly-aws-id/xslsx-attachment.xlsx", attachable_with_attachment.attachments.first.url
  end

  def test_unlink_attachment
    attachable_with_attachment.unlink_attachment(xlsx_attachment)

    assert_equal 0, attachable_with_attachment.attachments.size
  end

  def test_unlink_attachment_preserves_attachment
    attachable_with_attachment.unlink_attachment(xlsx_attachment)

    assert GobiertoAttachments::Attachment.exists?(xlsx_attachment.id)
  end

  def test_list_attachments
    attachables.each do |attachable|
      attachable.link_attachment(pdf_attachment)
      attachable.reload
    end

    assert_equal [pdf_attachment], attachable_without_attachment.attachments
    assert_equal [xlsx_attachment, pdf_attachment], attachable_with_attachment.attachments.order(:name)
  end
end
