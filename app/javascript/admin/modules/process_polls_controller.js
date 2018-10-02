import 'magnific-popup'
import 'webpack-jquery-ui/sortable'

window.GobiertoAdmin.ProcessPollsController = (function() {

  var $modalStateBackup;
  var restoreModalContentFlag = false;
  var deleteLastCreatedQuestionIdx;

  function ProcessPollsController() {}

  ProcessPollsController.prototype.edit = function() {

    // ** poll question handlers **

    _handleAddQuestion();

    _addDeleteQuestionBehaviors();
    _addEditQuestionBehaviors();
    _addConfirmEditQuestionBehaviors();
    _addEditQuestionModalBehaviors();
    _handleSortableQuestions();

    _addToggleAnswerTemplatesVisibilityBehaviors();

    // ** answer template handlers **

    _addAddAnswerTemplateBehaviors();
    _addEditAnswerTemplateBehaviors();
    _addConfirmEditAnswerTemplateBehaviors();
    _addCancelEditAnswerTemplateBehaviors();
    _addDeleteAnswerTemplateBehaviors();
    _handleSortableAnswerTemplates();
    _addAttachImageToAnswerTemplateBehaviors();

    // ** others **

    if ($('[data-behavior=disable_editable_components]').length > 0) {
      disableEditableComponents();
    }
  };

  function disableEditableComponents() {
    $('textarea, input, button, select').prop('disabled', true);

    // poll questions
    $('.poll_question_summary .ui-sortable-handle').removeClass('custom_handle');
    $('.poll_question_summary [data-behavior=delete_record]').remove();
    $('[data-behavior=add_question]').remove();
    $('[data-behavior=cancel_save_question]').remove();
    $('[data-behavior=save_question]').remove();

    // answer templates
    $('.answer_template .ui-sortable-handle').removeClass('custom_handle');
    $('.answer_template .tools').remove();
    $('[data-behavior=add_answer]').remove();
    $('.answer_template .list_item > label').css('margin-right', 0);
    $('.answer_template .list_item > label').css('width', 'calc(100% - 65px)');
  }

  function extractIndex(elementId) {
    var splitted = elementId.split('_');
    return splitted[splitted.length - 1];
  }

  function _addEditQuestionModalBehaviors() {

    // initialize modals
    $('.open_poll_modal').magnificPopup({
      type:'inline',
      removalDelay: 300,
      mainClass: 'mfp-fade',
      closeMarkup: "<button title='Close (Esc)' type='button' class='mfp-close close_poll_modal' data-behavior='cancel_save_question'>×</button>",
      closeOnBgClick: false,
      callbacks: {
        afterClose: function() {
          if (restoreModalContentFlag) {
            restoreModalContent();
          } else {
            updateQuestionSummaryTitle();
          }
        },
        // Add custom behaviors to the upper right cancel edit question button (the X).
        // This button is added by Magnific Popup JS when the modal is opened, so
        // behaviors must be added in a callback (afterOpen callback does not exist,
        // but this one works)
        open: function() {
          $('.close_poll_modal').unbind('click', closeModal).click(closeModal);

          // set focus on title input
          var questionIdx = extractIndex($.magnificPopup.instance.currItem.src);
          var closestLocale = $('#edit_question_' + questionIdx).find('.globalized_fields').find('a.selected').text().trim().toLowerCase();
          var $titleInput = $('#poll_questions_attributes_' + questionIdx + '_title_translations_' + closestLocale);

          setTimeout(function(){ $titleInput.focus() }, 60);
        }
      }
    });

    $('.close_poll_modal').unbind('click', closeModal)
                          .click(closeModal);
  }

  function restoreModalContent() {
    var modalId = $modalStateBackup.attr('id');
    var $questionModalWrapper = $('#' + modalId);

    $questionModalWrapper.replaceWith($modalStateBackup);

    _addEditQuestionModalBehaviors();
    window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
    _addAddAnswerTemplateBehaviors();
    _addEditAnswerTemplateBehaviors();
    _addConfirmEditAnswerTemplateBehaviors();
    _addCancelEditAnswerTemplateBehaviors();
    _addDeleteAnswerTemplateBehaviors();
    _handleSortableAnswerTemplates();

    if(deleteLastCreatedQuestionIdx) {
      var splitted = modalId.split('_');
      var $questionSummaryWrapper = $('#question_summary_' + splitted[splitted.length - 1]);

      $questionModalWrapper.remove();
      $questionSummaryWrapper.remove();

      deleteLastCreatedQuestionIdx = undefined;
    }

    restoreModalContentFlag = false;
  }

  function updateQuestionSummaryTitle() {
    var questionIdx = extractIndex($modalStateBackup.attr('id'));
    var questionTitle = $('#poll_questions_attributes_' + questionIdx + '_title_translations_' + I18n.locale).val();

    if (questionTitle === undefined || questionTitle === "") {
      questionTitle = I18n.t('gobierto_admin.gobierto_participation.processes.polls.question_not_translated');
    }

    $('#question_summary_' + questionIdx).find('label').text(questionTitle);
  }

  function closeModal(e) {
    if ($(e.target).attr('data-behavior') === 'cancel_save_question') {
      restoreModalContentFlag = true;
    } else {
      e.preventDefault();
    }
    $.magnificPopup.close();
  }

  function _handleAddQuestion() {
    var $addQuestionLinks = $('a[data-behavior=add_question]');

    $addQuestionLinks.click(function(e) {

      e.preventDefault();

      var $existingQuestions = $('.poll_question_summary');
      var questionIdx = $existingQuestions.length;

      createNewQuestionModal(questionIdx);
      createNewQuestionSummary($existingQuestions, questionIdx);
      deleteLastCreatedQuestionIdx = questionIdx; // will be removed if clicking on cancel button
    });
  }

  function createNewQuestionSummary($existingQuestions, questionIdx) {
    var $questionSummaryScaffold = $('#question_summary_scaffold');

    var $newQuestionSummary = $questionSummaryScaffold.clone();

    $newQuestionSummary.removeAttr('style')
                       .attr('id', 'question_summary_' + questionIdx)
                       .addClass('poll_question_summary');

    $newQuestionSummary.find('a[data-behavior=edit_record]')
                       .attr('href', '#edit_question_' + questionIdx);

    $('#poll_questions_summaries').append($newQuestionSummary.prop('outerHTML'));

    _addEditQuestionBehaviors();
    _addDeleteQuestionBehaviors();
    _addEditQuestionModalBehaviors();
    _addConfirmEditQuestionBehaviors();

    saveQuestionModalState(questionIdx);

    // Single instance of magnificPopup with several items inside. Open the last one.
    $('[href="#edit_question_' + questionIdx + '"]').magnificPopup('open', questionIdx + 1);
  }

  function createNewQuestionModal(questionIdx) {
    var $questionModalScaffold = $('#edit_question_modal_scaffold');

    var $newQuestionModal = $questionModalScaffold.clone();
    $newQuestionModal.attr('id', 'edit_question_' + questionIdx);

    // add to DOM
    var $existingQuestionModals = $('.modal');
    $existingQuestionModals.last().after($newQuestionModal);

    // reload selector
    $newQuestionModal = $('#edit_question_' + questionIdx);

    // update question destroy flag
    var $newQuestionDestroyInput = $newQuestionModal.find('#new_question_destroy_scaffold_input');
    $newQuestionDestroyInput.attr('name', 'poll[questions_attributes][' + questionIdx + '][_destroy]')
                            .attr('id', 'poll_questions_attributes_' + questionIdx + '__destroy')
                            .val('0');

    // update question order
    var $newQuestionOrderInput = $newQuestionModal.find('#new_question_order_scaffold_input');
    $newQuestionOrderInput.attr('name', 'poll[questions_attributes][' + questionIdx + '][order]')
                          .attr('id', 'poll_questions_attributes_' + questionIdx + '_order')
                          .val($('.poll_question_summary').length);

    // update title translations labels attributes
    $newQuestionModal.find('label').each(function() {
      var forAttribute = $(this).attr('for');
      if (forAttribute !== undefined && forAttribute.match(/poll_questions_attributes_scaffold_title_translations_../)) {
        var newForAttribute = forAttribute.replace('scaffold', questionIdx);
        $(this).attr('for', newForAttribute);
      }
    });

    // update title translations inputs attributes
    $newQuestionModal.find('input').each(function() {
      var nameAttribute = $(this).attr('name');
      if (nameAttribute !== undefined && nameAttribute.match(/poll\[questions_attributes\]\[scaffold\]\[title_translations\]\[..\]/)) {
        var newNameAttribute = nameAttribute.replace('scaffold', questionIdx);
        $(this).attr('name', newNameAttribute)
               .attr('id', $(this).attr('id').replace('scaffold', questionIdx));
      }
    });

    // update question type checkboxes attributes
    $newQuestionModal.find('.option').each(function() {
      var $input = $(this).find('input');
      var id = $input.attr('id');

      if (id && id.match(/poll_questions_attributes_scaffold_answer_type_.*/)) {
        var newId = id.replace('scaffold', questionIdx);

        $input.attr('id', newId)
              .attr('name', 'poll[questions_attributes][' + questionIdx + '][answer_type]');

        $(this).find('label').attr('for', newId);
      }
    });

    // add behaviors to all new intputs, links, etc.
    _addAddAnswerTemplateBehaviors();
    _addToggleAnswerTemplatesVisibilityBehaviors();
    window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
  }

  function _addDeleteQuestionBehaviors() {
    var $destroyLinks = $('a[data-behavior=delete_record]');

    $destroyLinks.off('click').click(handleDeleteQuestion);
  }

  function handleDeleteQuestion(e) {
    e.preventDefault();

    var $summaryWrapper = $(this).closest('.list_item');
    var questionIdx = extractIndex($summaryWrapper.attr('id'));

    var $destroyFlag = $('#poll_questions_attributes_' + questionIdx + '__destroy');
    var $questionModalWrapper = findQuestionModal(questionIdx);

    $destroyFlag.prop('value', '1');
    $summaryWrapper.hide();
    $questionModalWrapper.hide();
  }

  function _addEditQuestionBehaviors() {
    var $editLinks = $('a[data-behavior=edit_record]');

    $editLinks.off('click').click(handleEditQuestion);
  }

  function handleEditQuestion(e) {
    e.preventDefault();

    var $summaryWrapper = $(this).closest('.list_item');
    var questionIdx = extractIndex($summaryWrapper.attr('id'));

    saveQuestionModalState(questionIdx);
  }

  function _addConfirmEditQuestionBehaviors() {
    var $saveQuestionButtons = $('[data-behavior=save_question]');

    $saveQuestionButtons.off('click').click(handleConfirmEditQuestion);
  }

  function _handleSortableQuestions() {
    var $sortableQuestionsWrapper = $('#poll_questions_summaries');

    $($sortableQuestionsWrapper).sortable({
      items: '.poll_question_summary',
      handle: '.custom_handle',
      forcePlaceholderSize: true,
      placeholder: '<div class="list_item poll_question_summary"></div>',
      update: function() {
        refreshSortableQuestionsPositions($sortableQuestionsWrapper);
      }
    });
  }

  function refreshSortableQuestionsPositions($sortableQuestionsWrapper) {
    var positions = [];

    $sortableQuestionsWrapper.find('.poll_question_summary').each(function(index) {
      positions.push({
        questionIdx: extractIndex($(this).attr('id')),
        order: index
      });
    });

    // iterate through all forms, updating order hidden inputs
    positions.forEach(function(item) {
      var $questionOrderInput = $('#poll_questions_attributes_' + item['questionIdx'] + '_order');
      $questionOrderInput.val(item['order']);
    });
  }

  function handleConfirmEditQuestion() {
    // update the label in the summary.

    var $questionModalWrapper = $(this).closest('.modal');
    var questionIdx = extractIndex($questionModalWrapper.attr('id'));
    var $questionSummaryWrapper = $('#question_summary_' + questionIdx);

    var questionTitle = $('#poll_questions_attributes_' + questionIdx + '_title_translations_' + I18n.locale).val();

    if (questionTitle === undefined || questionTitle === "") {
      questionTitle = I18n.t('gobierto_admin.gobierto_participation.processes.polls.question_not_translated');
    }
    var $titleLabel = $questionSummaryWrapper.find('label');
    $titleLabel.text(questionTitle);

    deleteLastCreatedQuestionIdx = undefined;
  }

  function _addToggleAnswerTemplatesVisibilityBehaviors() {
    var $showAnswerTemplatesLinks = $('input[data-behavior=show_answer_templates]');
    var $hideAnswerTemplatesLinks = $('input[data-behavior=hide_answer_templates]');

    $showAnswerTemplatesLinks.off('click').click(function() {
      var $questionModalWrapper = $(this).closest('.modal');

      $questionModalWrapper.find('.question_answer_templates').show('slow');
    });

    $hideAnswerTemplatesLinks.off('click').click(function() {
      var $questionModalWrapper = $(this).closest('.modal');

      $questionModalWrapper.find('.question_answer_templates').hide('slow');
    });
  }

  function _addEditAnswerTemplateBehaviors() {
    var $editLinks = $('.edit_link');

    $editLinks.off('click').click(handleEditAnswerTemplate);
  }

  function handleEditAnswerTemplate(e) {
    e.preventDefault();

    var $questionModalWrapper = $(this).closest('.modal');
    var questionIdx = extractIndex($questionModalWrapper.attr('id'));

    var $previewAnswerWrapper = $(this).closest('.list_item');
    var answerIdx = extractIndex($previewAnswerWrapper.attr('id'));

    var $editAnswerWrapper = $('#question_' + questionIdx + '_edit_answer_' + answerIdx);

    $previewAnswerWrapper.hide();
    $editAnswerWrapper.show();

    // set focus on text input
    $('#poll_questions_attributes_' + questionIdx + '_answer_templates_attributes_' + answerIdx + '_text').focus();
  }

  function _addConfirmEditAnswerTemplateBehaviors() {
    var $confirmEditLinks = $('[data-behavior=confirm_edit_answer]');

    $confirmEditLinks.off('click').click(handleConfirmEditAnswerTemplate);
  }

  function handleConfirmEditAnswerTemplate(e) {
    e.preventDefault();

    var $questionModalWrapper = $(this).closest('.modal');
    var questionIdx = extractIndex($questionModalWrapper.attr('id'));

    var $editAnswerWrapper = $(this).closest('.list_item_with_editable_content');
    var answerIdx = extractIndex($editAnswerWrapper.attr('id'));

    var $previewAnswerWrapper = $('#question_' + questionIdx + '_preview_answer_' + answerIdx);

    // update label text with input text
    var $answerInput = $editAnswerWrapper.find("input[name='" + generateNameForAnswerTemplateAttribute(questionIdx, answerIdx, "text") + "']");
    var $answerLabel = $previewAnswerWrapper.find('.main label');
    $answerLabel.text($answerInput.val());

    $previewAnswerWrapper.show();
    $editAnswerWrapper.hide();
  }

  function _addCancelEditAnswerTemplateBehaviors() {
    var $cancelEditLinks = $('[data-behavior=cancel_edit_answer]');

    $cancelEditLinks.off('click').click(handleCancelEditAnswerTemplate);
  }

  function handleCancelEditAnswerTemplate(e) {
    e.preventDefault();

    var $questionModalWrapper = $(this).closest('.modal');
    var questionIdx = extractIndex($questionModalWrapper.attr('id'));

    var $editAnswerWrapper = $(this).closest('.list_item_with_editable_content');
    var answerIdx = extractIndex($editAnswerWrapper.attr('id'));

    var $previewAnswerWrapper = $('#question_' + questionIdx + '_preview_answer_' + answerIdx);

    // restore input text with label text
    var $answerInput = $editAnswerWrapper.find("input[name='" + generateNameForAnswerTemplateAttribute(questionIdx, answerIdx, "text") + "']");
    var $answerLabel = $previewAnswerWrapper.find('.main label');
    $answerInput.val($answerLabel.text());

    $previewAnswerWrapper.show();
    $editAnswerWrapper.hide();
  }

  function _addDeleteAnswerTemplateBehaviors() {
    var $deleteAnswerLinks = $('[data-behavior=delete_answer]');

    $deleteAnswerLinks.off('click').click(handleDeleteAnswerTemplate);
  }

  function _addAttachImageToAnswerTemplateBehaviors() {
    $('.js-file-input').off('change').change(function() {
      _loadImageInputPreview(this);
    });
  }

  function handleDeleteAnswerTemplate(e) {
    e.preventDefault();

    var $questionModalWrapper = $(this).closest('.modal');
    var questionIdx = extractIndex($questionModalWrapper.attr('id'));

    var $previewAnswerWrapper = $(this).closest('.list_item');
    var answerIdx = extractIndex($previewAnswerWrapper.attr('id'));

    var $editAnswerWrapper = $('#question_' + questionIdx + '_edit_answer_' + answerIdx);

    // avoid deleting, so there is no answer index overlap when creating new answers
    $previewAnswerWrapper.hide();
    $editAnswerWrapper.hide();

    $editAnswerWrapper.find('#' + generateIdForAnswerTemplateAttribute(questionIdx, answerIdx, '_destroy')).prop('value', '1');
  }

  function _addAddAnswerTemplateBehaviors() {
    var $addAnswerLinks = $('[data-behavior=add_answer]');

    $addAnswerLinks.off('click').click(handleAddAnswerTemplate);
  }

  function handleAddAnswerTemplate(e) {
    e.preventDefault();

    var $questionModalWrapper = $(this).closest('.modal');
    var questionIdx  = extractIndex($questionModalWrapper.attr('id'));
    var newAnswerIdx = $questionModalWrapper.find('.answer_template').length;

    var $answerTemplateScaffold = $questionModalWrapper.find('.answer_template_scaffold');

    var $newAnswerWrapper = $answerTemplateScaffold.clone();
    $newAnswerWrapper.addClass('answer_template')
                     .removeClass('answer_template_scaffold');

    var $newAnserPreviewPanel = $newAnswerWrapper.find('.list_item');
    $newAnserPreviewPanel.attr('id', 'question_' + questionIdx + '_preview_answer_' + newAnswerIdx);

    var $newAnswerEditPanel = $newAnswerWrapper.find('.list_item_with_editable_content');
    $newAnswerEditPanel.attr('id', 'question_' + questionIdx + '_edit_answer_' + newAnswerIdx)
                       .show();

    // set answer text input name and id according to Rails standard
    var $newAnswerTextInput = $newAnswerEditPanel.find('#new_answer_text_scaffold_input');
    $newAnswerTextInput.attr('name', generateNameForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'text'))
                       .attr('id', generateIdForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'text'));

    // set focus on text input (a little timeout is needed)
    setTimeout(function(){ $('#' + generateIdForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'text')).focus() }, 50);

    // set answer image_file input name and id according to Rails standard
    var $newAnswerImageInput = $newAnswerEditPanel.find('#new_answer_image_file_scaffold_input');
    $newAnswerImageInput.attr('name', generateNameForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'image_file'))
                        .attr('id', generateIdForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'image_file'));

    // set answer image_file label `for` attribute according to Rails standard
    var $newAnswerImageLabel = $newAnswerEditPanel.closest('.answer_template').find("label[for='new_answer_image_file_scaffold_input']");
    $newAnswerImageLabel.attr('for', generateIdForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'image_file'));

    // set answer order input id, name and value according to Rails standard
    var $newAnswerOrderInput = $newAnswerEditPanel.find('#new_answer_order_scaffold_input');
    $newAnswerOrderInput.attr('name', generateNameForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'order'))
                        .attr('id', generateIdForAnswerTemplateAttribute(questionIdx, newAnswerIdx, 'order'))
                        .attr('value', newAnswerIdx);

    // set answer destroy input id and name according to Rails standard
    var $newAnswerDestroyInput = $newAnswerEditPanel.find('#new_answer_destroy_scaffold_input');
    $newAnswerDestroyInput.attr('name', generateNameForAnswerTemplateAttribute(questionIdx, newAnswerIdx, '_destroy'))
                          .attr('id', generateIdForAnswerTemplateAttribute(questionIdx, newAnswerIdx, '_destroy'))
                          .val('0');

    // append at the end of all answer templates
    var answerTemplates = $questionModalWrapper.find('.question_answer_templates').children('.answer_template_scaffold, .answer_template');
    $(answerTemplates[answerTemplates.length - 1]).after($newAnswerWrapper.prop('outerHTML'));

    _addConfirmEditAnswerTemplateBehaviors();
    _addEditAnswerTemplateBehaviors();
    _addCancelEditAnswerTemplateBehaviors();
    _addDeleteAnswerTemplateBehaviors();
    _handleSortableAnswerTemplates();
    _addAttachImageToAnswerTemplateBehaviors();
  }

  function _handleSortableAnswerTemplates() {
    var $sortableAnswerTemplatesWrappers = $('.question_answer_templates');

    $sortableAnswerTemplatesWrappers.each(function(index, $sortableAnswerTemplatesWrapper) {
      $($sortableAnswerTemplatesWrapper).sortable({
        items: '.answer_template',
        handle: '.custom_handle',
        forcePlaceholderSize: true,
        placeholder: '<div class="answer_template"></div>',
        update: function() {
          refreshSortableAnswerTemplatesPositions($($sortableAnswerTemplatesWrapper));
        }
      });
    });
  }

  function refreshSortableAnswerTemplatesPositions($sortableAnswerTemplatesWrapper) {
    var positions = [];

    $sortableAnswerTemplatesWrapper.find('.answer_template > .list_item').each(function(index) {
      positions.push({
        answerTemplateIdx: extractIndex($(this).attr('id')),
        order: index
      });
    });

    // iterate through all answer templates, updating order hidden input

    var $questionModalWrapper = $sortableAnswerTemplatesWrapper.closest('.modal');
    var questionIdx = extractIndex($questionModalWrapper.attr('id'));

    positions.forEach(function(item) {
      var $answerTemplateOrderInput = $('#' + generateIdForAnswerTemplateAttribute(questionIdx, item['answerTemplateIdx'], 'order'));
      $answerTemplateOrderInput.val(item['order']);
    });
  }

  function saveQuestionModalState(questionIdx) {
    var $questionModalWrapper = findQuestionModal(questionIdx);
    $modalStateBackup = $questionModalWrapper.clone();
  }

  function findQuestionModal(questionIdx) {
    return $('#edit_question_' + questionIdx);
  }

  function generateNameForAnswerTemplateAttribute(questionIdx, answerIdx, attributeName) {
    return 'poll[questions_attributes][' + questionIdx + '][answer_templates_attributes][' + answerIdx + '][' + attributeName + ']';
  }

  function generateIdForAnswerTemplateAttribute(questionIdx, answerIdx, attributeName) {
    return 'poll_questions_attributes_' + questionIdx + '_answer_templates_attributes_' + answerIdx + '_' + attributeName;
  }

  function _loadImageInputPreview(input) {
    var validImageTypes = ["image/gif", "image/jpeg", "image/png"];

    if (input.files && input.files[0] && ($.inArray(input.files[0]["type"], validImageTypes) >= 0)) {
      var reader = new FileReader();

      reader.onload = function(e) {
        var $answerTemplate = $(input).closest(".answer_template");
        var $newImageWrapper = $answerTemplate.find(".js-new-image-wrapper");
        $answerTemplate.find(".js-old-image-wrapper").hide();
        $newImageWrapper.find("img")[0].src = e.target.result;
        $newImageWrapper.show();
      }

      reader.readAsDataURL(input.files[0]);
    }
  }

  return ProcessPollsController;
})();

window.GobiertoAdmin.process_polls_controller = new GobiertoAdmin.ProcessPollsController;
