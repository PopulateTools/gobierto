class CreateProcessStagesPlaceholders < ActiveRecord::Migration[5.1]

  def self.up
    # flag all existing stages as 'active'
    ::GobiertoParticipation::ProcessStage.update_all(active: true)

    # create all missing stages placeholders, as active: false
    all_stage_types = GobiertoParticipation::ProcessStage.stage_types.keys

    ::GobiertoParticipation::Process.all.each do |process|
      existing_stage_types = process.stages.pluck(:stage_type)
      missing_stages = all_stage_types - existing_stage_types
      missing_stages.each do |stage_type_name|
        ::GobiertoParticipation::ProcessStage.create!(
          process_id: process.id,
          slug: stage_type_name,
          stage_type: ::GobiertoParticipation::ProcessStage.stage_types[stage_type_name],
          active: false          
        )
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end
