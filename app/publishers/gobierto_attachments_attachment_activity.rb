# frozen_string_literal: true

module Publishers
  class GobiertoAttachmentsAttachmentActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_attachments_attachments"
  end
end
