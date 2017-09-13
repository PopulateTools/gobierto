module GobiertoParticipation
  module Processes
    class PollAnswersController < BaseController

      def new
        if current_poll.answerable_by?(current_user)
          @poll_answer_form = PollAnswerForm.new(poll: current_poll)
          render :new, layout: 'gobierto_participation/layouts/application_simple'
        else
          redirect_to(
            gobierto_participation_process_polls_path(current_process.slug),
            alert: t('.already_answered')
          )
        end
      end

      def create
        @poll_answer_form = PollAnswerForm.new(poll_answers_params.merge(user: current_user))

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
        current_process.polls.find(params[:poll_id])
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

    end
  end
end
