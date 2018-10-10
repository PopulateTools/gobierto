# frozen_string_literal: true

require 'test_helper'

module GobiertoParticipation
  module Processes
    class PollAnswersCreateTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def poll
        @poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
      end

      def poll_with_images
        @poll_with_images ||= gobierto_participation_polls(:neighbor_opinion_poll)
      end

      def user
        @user ||= users(:peter)
      end

      def user_already_answered
        @user_already_answered ||= users(:dennis)
      end

      def process_polls_path
        @process_polls_path ||= gobierto_participation_process_polls_path(
          process_id: process.slug
        )
      end

      def answer_poll_path(default_poll = poll)
        @answer_poll_path ||= new_gobierto_participation_process_poll_answer_path(process.slug, default_poll)
      end

      def test_answer_poll
        with_javascript do
          with_signed_in_user(user) do
            visit process_polls_path

            within "#poll_#{poll.id}" do
              click_link 'Participate in this poll'
            end

            # answer first question

            find('label', text: 'Si').trigger(:click)

            find('input.next_question').click

            # answer second question

            find('label', text: 'Horarios').trigger(:click)
            find('label', text: 'Características de los cenadores').trigger(:click)

            find('input.next_question').click

            # answer third question

            fill_in 'poll[questions_attributes][2][answers_attributes][0][text]', with: 'Some text…'

            # submit poll answers

            find('input.next_question').click

            sleep 1

            click_link 'x'

            answers = poll.answers.by_user(user)
            fixed_answers = answers.fixed_answers
            open_answers = answers.open_answers

            assert_equal 3, fixed_answers.size
            assert_equal 1, open_answers.size

            fixed_answers_text = fixed_answers.map{ |a| a.answer_template.text }

            assert array_match(['Si', 'Horarios', 'Características de los cenadores'], fixed_answers_text)
            assert_equal 'Some text…', open_answers.first.text
          end
        end
      end

      def test_answer_previously_answered_poll
        with_signed_in_user(user_already_answered) do

          visit answer_poll_path

          assert has_message? 'You have already participated in this poll'
        end
      end

      def test_answer_poll_with_images
        with_javascript do
          with_signed_in_user(user) do
            visit answer_poll_path(poll_with_images)

            # answer first question
            find("label", text: "Yes").trigger(:click)
            find("input.next_question").click

            # lightbox is not yet visible
            assert page.has_css?("#lightbox", visible: false)

            # click on image preview
            sleep 2
            first(".poll_option").first("a").click

            assert_equal(
              poll_with_images.questions.second.answer_templates.first.image_url,
              find("#lightbox img")[:src]
            )
          end
        end
      end

    end
  end
end
