# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class PollAnswersController < BaseController

      include User::VerificationHelper

      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action { check_active_stage(current_process, ProcessStage.stage_types[:polls]) }

      def new
        if !current_poll.has_answers_from?(current_user)
          @poll_answer_form = PollAnswerForm.new(poll: current_poll)
          render :new, layout: 'gobierto_participation/layouts/application_simple'
        else
          redirect_to(
            gobierto_participation_process_polls_path(current_process.slug),
            alert: t('.already_answered')
          )
        end
      end

      # PSEUDO-BUG: if both admin session and user session exist in different browser tabs, when admin clicks
      # on preview link, it can happen that if he submit poll, it will be submitted with the user session
      def create
        @poll_answer_form = PollAnswerForm.new(poll_answers_params.merge(user: current_user, poll: current_poll))

        if @poll_answer_form.save
          http_status = :ok
        else
          http_status = :bad_request
        end

        respond_to do |format|
          format.js do
            head http_status
          end
        end
      end

      private

      def current_poll
        polls_scope.find(params[:poll_id])
      end

      def poll_answers_params
        params.require(:poll).permit(
          questions_attributes: [
            :id,
            answers_attributes: [
              :answer_template_id,
              :text
            ]
          ]
        )
      end

      def polls_scope
        valid_preview_token? ? current_process.polls : current_process.polls.answerable
      end

    end
  end
end
