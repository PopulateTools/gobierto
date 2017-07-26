class AddTimestampsGobiertoAttachmentsAttachment < ActiveRecord::Migration[5.1]
  def change
    add_timestamps :ga_attachments, default: DateTime.current
    change_column_default :ga_attachments, :created_at, nil
    change_column_default :ga_attachments, :updated_at, nil
  end
end
