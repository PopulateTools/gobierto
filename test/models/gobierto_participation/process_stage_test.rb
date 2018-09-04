# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessStageTest < ActiveSupport::TestCase

    def process
      @process ||= gobierto_participation_processes(:complete_process)
    end

    def process_stage
      @process_stage ||= gobierto_participation_process_stages(:complete_process_information_stage)
    end

    def stages
      process.stages
    end

    def test_valid
      assert process_stage.valid?
    end

    def test_published
      assert process.stages.first.published?
    end

    def test_upcoming
      process.stages.last.upcoming?
    end

    def test_current
      assert stages.fourth.current?
    end

    def test_to_path
      information_stage = stages.information.first
      agenda_stage = stages.agenda.first
      polls_stage = stages.polls.first
      contributions_stage = stages.contributions.first
      documents_stage = stages.documents.first
      pages_stage = stages.pages.first

      assert_equal "/pagina/privacy?process_id=#{process.slug}", information_stage.to_path
      assert_equal "/participacion/p/#{process.slug}/agendas", agenda_stage.to_path
      assert_equal "/participacion/p/#{process.slug}/encuestas", polls_stage.to_path
      assert_equal "/participacion/p/#{process.slug}/aportaciones", contributions_stage.to_path
      assert_equal "/participacion/p/#{process.slug}/documentos", documents_stage.to_path
      assert_equal "/participacion/p/#{process.slug}/noticias", pages_stage.to_path
    end

    def test_public?
      assert process_stage.public?

      process.draft!

      refute process_stage.public?

      process_stage.draft!

      refute process_stage.public?

      process.active!

      refute process_stage.public?
    end

  end
end
