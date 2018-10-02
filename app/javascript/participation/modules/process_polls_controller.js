import Lightbox from 'lightbox2'

window.GobiertoParticipation.ProcessPollsController = (function() {

  function ProcessPollsController() {}

  ProcessPollsController.prototype.show = function(){
    Lightbox.init()

    _addNextQuestionButtonBehaviors();
    _preventAnchorsDefaultBehavior();
    _addQuestionOptionsBehaviors();
    refreshNextQuestionButtonState();

    $('form').bind('ajax:success', showSharePollPage);
    $('form').bind('ajax:error', showCannotSavePollPage);
  };

  // Checks if a question is answered to show the Next or Send button.
  function refreshNextQuestionButtonState() {
    var $submitInput = $("input[data-behavior='next_question']");
    var $currentQuestion = getCurrentQuestion();

    var $inputs = $currentQuestion.find('input');
    var inputType = $inputs.attr('type');

    if (inputType === 'radio' || inputType === 'checkbox') {
      if ($currentQuestion.find('label.checked').length >= 1) {
        $submitInput.prop('disabled', false)
      } else {
        $submitInput.prop('disabled', true)
      }
    }
  }

  function showPollContentItem($content) {
    $content.velocity("transition.slideRightIn", { duration: 250, delay: 250 })
            .addClass('question_active');
  }

  function hidePollContentItem($content) {
    $content.velocity("transition.slideLeftOut", { duration: 250 })
            .removeClass('question_active');
  }

  function getCurrentQuestion() {
    return $('.question_active');
  }

  function showSharePollPage() {
    refreshPageCounter();

    var $sharePollPage = $('[data-behavior="share_poll_page"]');

    hidePollContentItem(getCurrentQuestion());
    showPollContentItem($sharePollPage);
  }

  function showCannotSavePollPage() {
    refreshPageCounter();

    var $errorPage = $('[data-behavior="error_saving_poll"]');

    hidePollContentItem(getCurrentQuestion());
    showPollContentItem($errorPage);
  }

  function refreshPageCounter() {
    var $progressMapWrapper = $('.poll_progress_map');
    var $pageCounter = $progressMapWrapper.find('.poll_page');

    // refresh page number
    var pageTextArray = $pageCounter.text().trim().split(' ');
    pageTextArray[0] = parseInt(pageTextArray[0]) + 1;
    $pageCounter.text(pageTextArray.join(' '));

    // refresh progress bar
    $($progressMapWrapper.find('li').not('.active')[0]).addClass('active');
  }

  function _addQuestionOptionsBehaviors() {
    $('.poll_content .button').click(function() {
      var $input = $('#' + $(this).attr('for'));

      if ($input.attr('type') === 'radio') {

        var $pollQuestionWrapper = $(this).closest('.poll_question');
        var checked = $(this).hasClass('checked');
        $pollQuestionWrapper.find('label').removeClass('checked');

        if (!checked) {
          $(this).addClass('checked');
        } else {
          $(this).removeClass('checked');
        }

      } else {
        $(this).toggleClass('checked');
      }
      refreshNextQuestionButtonState();
    });
  }

  function extractIndex(elementId) {
    var splitted = elementId.split('_');
    return splitted[splitted.length - 1];
  }

  function _preventAnchorsDefaultBehavior() {
    var $anchors = $('.poll_option').find('a');

    $anchors.click(function(e) {
      e.preventDefault();
    });
  }

  function _addNextQuestionButtonBehaviors() {
    var $submitInput = $("input[data-behavior='next_question']");

    $submitInput.click(function(e) {
      var $questions = $('.poll_question');
      var $currentQuestion = getCurrentQuestion();
      var currentQuestionIndex = parseInt(extractIndex($currentQuestion.attr('id')));

      if (currentQuestionIndex !== $questions.length - 1) {

        e.preventDefault();

        var nextQuestionIndex = currentQuestionIndex + 1;
        var $nextQuestion = $('#poll_question_' + nextQuestionIndex);

        hidePollContentItem($currentQuestion);
        showPollContentItem($nextQuestion);

        if (nextQuestionIndex == $questions.length - 1) {
          $submitInput.val(I18n.t('gobierto_participation.processes.poll_answers.new.submit'));
        }

        refreshPageCounter();
        refreshNextQuestionButtonState();
      } else {
        $('.poll_actions').hide();
        // form is submitted by JavaScript
      }
    });
  }

  return ProcessPollsController;
})();

window.GobiertoParticipation.process_polls_controller = new GobiertoParticipation.ProcessPollsController;
