# frozen_string_literal: true

module GobiertoParticipation
  module ProcessStagesHelper
    extend ActiveSupport::Concern

    private

    def check_active_stage(process, stage_type)
      unless process.active_stage?(stage_type)
        redirect_to gobierto_participation_process_path(process.slug), notice: t("concerns.gobierto_participation.process_stages_helper.stage_not_active")
        false
      end
    end

  end
end
