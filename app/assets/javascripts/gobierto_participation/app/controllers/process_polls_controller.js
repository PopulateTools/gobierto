this.GobiertoParticipation.ProcessPollsController = (function() {
  function ProcessPollsController() {}

  ProcessPollsController.prototype.show = function(){

    _addNextQuestionButtonBehaviors();
    _preventAnchorsDefaultBehavior();
    _addQuestionOptionsBehaviors();

    $('form').bind('ajax:success', showSharePollPage);
    $('form').bind('ajax:error', showCannotSavePollPage);
  };

  function showSharePollPage() {
    refreshPageCounter();

    $currentQuestion = $('.question_active');
    $sharePollPage = $('[data-behavior="share_poll_page"]');

    $currentQuestion.velocity("transition.slideLeftOut", { duration: 250 })
                    .removeClass('question_active');

    $sharePollPage.velocity("transition.slideRightIn", { duration: 250, delay: 250 })
                  .addClass('question_active');
  }

  function showCannotSavePollPage() {
    refreshPageCounter();

    $currentQuestion = $('.question_active');
    $errorPage = $('[data-behavior="error_saving_poll"]');

    $currentQuestion.velocity("transition.slideLeftOut", { duration: 250 })
                    .removeClass('question_active');

    $errorPage.velocity("transition.slideRightIn", { duration: 250, delay: 250 })
              .addClass('question_active');
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
    $('.poll_content .button').click(function(e) {
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
    });
  }

  function extractIndex(elementId) {
    var splitted = elementId.split('_');
    return splitted[splitted.length - 1];
  };

  function _preventAnchorsDefaultBehavior() {
    var $anchors = $('.poll_option').find('a');

    $anchors.click(function(e) {
      e.preventDefault();
    });
  };

  function _addNextQuestionButtonBehaviors() {

    var $submitInput = $("input[data-behavior='next_question']");

    $submitInput.click(function(e) {
      var $questions = $('.poll_question');
      var $currentQuestion = $('.question_active');
      var currentQuestionIndex = parseInt(extractIndex($currentQuestion.attr('id')));

      if (currentQuestionIndex !== $questions.length - 1) {

        e.preventDefault();
        
        var nextQuestionIndex = currentQuestionIndex + 1;
        var $nextQuestion = $('#poll_question_' + nextQuestionIndex);

        $currentQuestion.velocity("transition.slideLeftOut", { duration: 250 })
                        .removeClass('question_active');

        $nextQuestion.velocity("transition.slideRightIn", { duration: 250, delay: 250 })
                     .addClass('question_active');

        if (nextQuestionIndex == $questions.length - 1) {
          $submitInput.val("Submit");
        }

        refreshPageCounter();
      } else {
        $('.poll_actions').hide();
        // form is submitted by JavaScript
      }
    });
  };

  return ProcessPollsController;
})();

this.GobiertoParticipation.process_polls_controller = new GobiertoParticipation.ProcessPollsController;
