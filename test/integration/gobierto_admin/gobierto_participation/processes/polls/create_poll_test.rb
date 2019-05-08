# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoParticipation
    class CreatePollTest < ActionDispatch::IntegrationTest

      def setup
        super
        @path = admin_participation_process_polls_path(process)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      # Outline of actions:
      #   1. Create new poll
      #   2. Create single choice question for poll
      #     2a. Create first answer template
      #     2b. Create second answer template
      #   3. Create open answer question for poll
      #   4. Assertions about poll
      #   5. Assertions about questions
      #   6. Assertions about answer templates
      def test_create_poll
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              # fill in poll data

              click_link 'New'

              within 'form.new_poll' do
                fill_in 'poll_title_translations_en', with: 'New poll title'
                fill_in 'poll_description_translations_en', with: 'New poll description'

                click_link 'ES'

                fill_in 'poll_title_translations_es', with: 'Título de la nueva encuesta'
                fill_in 'poll_description_translations_es', with: 'Descripción de la nueva encuesta'

                fill_in 'poll_starts_at', with: '2017-01-15'
                fill_in 'poll_ends_at',   with: '2017-02-16'
              end

              # add single-choice question to poll

              click_link 'Add new question'

              within '#edit_question_0' do
                find('#poll_questions_attributes_0_title_translations_en', visible: false).set('Single choice question text')
                find('#poll_questions_attributes_0_answer_type_single_choice', visible: false).execute_script("this.click()")

                # add available answer 0

                find('a[data-behavior=add_answer]', visible: false).execute_script("this.click()")

                fill_in 'poll_questions_attributes_0_answer_templates_attributes_0_text', with: 'First answer to single-choice question'

                within '#question_0_edit_answer_0' do
                  find('a[data-behavior=confirm_edit_answer]', visible: false).execute_script("this.click()")
                end

                # add available answer 1

                find('a[data-behavior=add_answer]', visible: false).execute_script("this.click()")

                fill_in 'poll_questions_attributes_0_answer_templates_attributes_1_text', with: 'Second answer to single-choice question'

                within '#question_0_edit_answer_1' do
                  find('a[data-behavior=confirm_edit_answer]', visible: false).execute_script("this.click()")
                end

                click_button 'Save'
              end

              # add open answer question to poll

              click_link 'Add new question'

              within '#edit_question_1' do
                find('#poll_questions_attributes_1_title_translations_en', visible: false).set('Open answer question text')
                find('#poll_questions_attributes_1_answer_type_open', visible: false).execute_script("this.click()")

                click_button 'Save'
              end

              # create poll

              within 'form.new_poll' do
                click_button 'Create'
              end

              assert has_message? 'Poll created successfully'

              visit @path

              assert has_content? 'New poll title'

              # assertions about the poll

              poll = process.polls.last

              assert_equal 'New poll title', poll.title
              assert_equal 'New poll description', poll.description
              assert_equal 'Título de la nueva encuesta', poll.title_es
              assert_equal 'Descripción de la nueva encuesta', poll.description_es
              assert_equal Date.parse('15-01-2017'), poll.starts_at
              assert_equal Date.parse('16-02-2017'), poll.ends_at

              # assertions about questions

              questions = poll.questions

              assert_equal 2, questions.size

              single_choice_question = questions.first
              open_question = questions.second

              assert_equal 'Single choice question text', single_choice_question.title
              assert_equal ::GobiertoParticipation::PollQuestion.answer_types[:single_choice], single_choice_question.answer_type
              assert_equal 0, single_choice_question.order

              assert_equal 'Open answer question text', open_question.title
              assert_equal ::GobiertoParticipation::PollQuestion.answer_types[:open], open_question.answer_type
              assert_equal 1, open_question.order

              # assertions about the answer templates

              answer_templates = single_choice_question.answer_templates

              assert_equal 2, answer_templates.size

              first_answer_template = answer_templates.first
              second_anwer_template = answer_templates.second

              assert_equal 'First answer to single-choice question',  first_answer_template.text
              assert_equal 0, first_answer_template.order

              assert_equal 'Second answer to single-choice question', second_anwer_template.text
              assert_equal 1, second_anwer_template.order
            end
          end
        end
      end

    end
  end
end
