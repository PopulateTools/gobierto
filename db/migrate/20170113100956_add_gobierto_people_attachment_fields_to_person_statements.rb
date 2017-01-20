class AddGobiertoPeopleAttachmentFieldsToPersonStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_person_statements, :attachment_url, :string
    add_column :gp_person_statements, :attachment_size, :integer
  end
end
