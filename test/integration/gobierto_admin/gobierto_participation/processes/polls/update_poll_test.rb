# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class UpdatePollTest < ActionDispatch::IntegrationTest

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def poll
        @poll ||= gobierto_participation_polls(:public_spaces_future)
      end

      def open_poll
        @open_poll ||= gobierto_participation_polls(:pedestrianization_published)
      end

      def edit_poll_path(poll)
        edit_admin_participation_process_poll_path(process, poll)
      end

      # Outline of actions:
      #   1. Edit poll data
      #   2. Delete existing question
      #   3. Edit existing question
      #     3a. Delete existing answer template
      #     3b. Edit existing answer template
      #     3c. Add new answer template
      #   4. Create new question (open answer, for simplicity)
      #   5. Assertions about poll
      #   6. Assertions about edited question
      #     6a. Assertions about edited question answer templates
      #   7. Assertions about new question
      def test_update_poll
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_poll_path(poll)

              # edit poll data

              fill_in 'poll_title_translations_en', with: 'Edited poll title'

              # delete first question

              within('#question_summary_0') { find('a[data-behavior=delete_record]').click }

              # edit second question

              within('#question_summary_1') { find('a[data-behavior=edit_record]').click }

              within('#edit_question_1', visible: false) do
                # find('#poll_questions_attributes_1_title_translations_en', visible: false).set('Edited question title')
                page.execute_script('document.getElementById("poll_questions_attributes_1_title_translations_en").innerText = "Edited question title"')

                # find('#poll_questions_attributes_1_title_translations_es', visible: false).set('Título de pregunta editado')
                page.execute_script('document.getElementById("poll_questions_attributes_1_title_translations_es").innerText = "Título de pregunta editado"')

                find('#poll_questions_attributes_1_answer_type_single_choice', visible: false).execute_script("this.click()")
              end

              # delete second question first answer template

              within('#question_1_preview_answer_0', visible: false) do
                find('a[data-behavior=delete_answer]', visible: false).execute_script("this.click()")
              end

              # edit second question second answer template

              within('#question_1_edit_answer_1', visible: false) do
                # find('#poll_questions_attributes_1_answer_templates_attributes_1_text', visible: false).set('Edited answer text')
                page.execute_script('document.getElementById("poll_questions_attributes_1_answer_templates_attributes_1_text").innerText = "Edited answer text"')

                find('a[data-behavior=confirm_edit_answer]', visible: false).execute_script("this.click()")
              end

              # add new answer template

              within('#edit_question_1', visible: false) do
                find('a[data-behavior=add_answer]', visible: false).execute_script("this.click()")
              end

              # find('#poll_questions_attributes_1_answer_templates_attributes_3_text', visible: false).set('New answer text')
              page.execute_script('document.getElementById("poll_questions_attributes_1_answer_templates_attributes_3_text").innerText = "New answer text"')

              within('#question_1_edit_answer_3', visible: false) do
                find('a[data-behavior=confirm_edit_answer]', visible: false).execute_script("this.click()")
              end

              # save question

              within('#edit_question_1', visible: false) { click_button 'Save', visible: false }

              # create new open answer question

              click_link 'Add new question'

              within '#edit_question_3' do
                # find('#poll_questions_attributes_3_title_translations_en', visible: false).set('Open answer question text')
                page.execute_script('document.getElementById("poll_questions_attributes_3_title_translations_en").innerText = "Open answer question text"')

                find('#poll_questions_attributes_3_answer_type_open', visible: false).execute_script("this.click()")

                click_button 'Save'
              end

              # submit form

              click_button 'Update'

              assert has_message? 'Poll has been updated'

              # assertions about poll

              poll.reload

              assert_equal 'Edited poll title', poll.title

              # assertions about questions

              questions = poll.questions

              assert_equal 3, questions.size

              # assertions about edited question

              edited_question = questions.first

              assert_equal 'Edited question title', edited_question.title
              assert_equal 'Título de pregunta editado', edited_question.title_es
              assert_equal ::GobiertoParticipation::PollQuestion.answer_types[:single_choice], edited_question.answer_type
              assert_equal 0, edited_question.order

              # assertions about edited question answer templates

              answer_templates = edited_question.answer_templates

              assert_equal 3, answer_templates.size

              edited_answer_template = answer_templates.find_by(text: 'Edited answer text')
              new_answer_template    = answer_templates.find_by(text: 'New answer text')

              assert_equal 0, edited_answer_template.order
              assert_equal 2, new_answer_template.order

              # assertions about new question

              new_question = questions.last

              assert_equal 'Open answer question text', new_question.title
              assert_equal ::GobiertoParticipation::PollQuestion.answer_types[:open], new_question.answer_type
              assert_equal 2, new_question.order
            end
          end
        end
      end

      def test_preview_poll_in_front
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_poll_path(process, open_poll)

            within ".widget_save" do
              find("label", text: "Published").click
              click_button "Update"
            end

            within("header") { click_link "View item" }

            sleep 2

            assert current_url.include? open_poll.to_url
            # always include preview token since the admin may not have session in the front
            assert current_url.include? "preview_token=#{admin.preview_token}"
          end
        end
      end

    end
  end
end
