class RemoveModuleCitizensCharters < ActiveRecord::Migration[6.0]
  def up
    GobiertoCommon::CustomFieldRecord.where(item_type: 'GobiertoCitizensCharters::Charter').each(&:delete)
    GobiertoCommon::CustomField.where(class_name: 'GobiertoCitizensCharters::Charter').each(&:delete)

    GobiertoCommon::CustomFieldRecord.where(item_type: 'GobiertoCitizensCharters::Service').each(&:delete)
    GobiertoCommon::CustomField.where(class_name: 'GobiertoCitizensCharters::Service').each(&:delete)

    drop_table :gcc_services
    drop_table :gcc_charters
    drop_table :gcc_commitments
    drop_table :gcc_editions

    Site.all.each do |s|
      s.configuration_data["modules"].delete("GobiertoCitizenCharters")
      s.configuration_data["modules"].first if s.configuration_data["home_page"] == "GobiertoCitizenCharters"
      s.save
    end
  end

  def down
  end
end
