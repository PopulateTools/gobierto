this.GobiertoAdmin.ProcessesController = (function() {

  var $stageModalBackup;
  var restoreModalContentFlag = false;

  function ProcessesController() {}

  ProcessesController.prototype.form = function() {

    _addMagnificPopupBehaviors();
    _addEditStageBehaviors();
    _addCloseModalBehaviors();
    _addSetProcessDurationBehavior();
    _handleSortableList();
    _modifyActiveStage();
  };

  function _modifyActiveStage() {
    var str = window.location.href;
    var subStr= str.match("(.*)/processes/(.*)/edit");
    $("input[name='process[stages_attributes][active]']").click(function(){
        $.ajax({
            type: "POST",
            url: '/admin/participation/processes/' + subStr[2] + '/update_current_stage',
            type: 'POST',
            dataType: 'json',
            data: { active_stage_id: $("input[name='process[stages_attributes][active]']:checked").val() }
        });
    });
  };

  function _addMagnificPopupBehaviors() {
    // initialize one modal with several associated items
    $('[data-behavior=edit_stage]').magnificPopup({
      type:'inline',
      removalDelay: 300,
      mainClass: 'mfp-fade',
      closeMarkup: "<button title='Close (Esc)' type='button' class='mfp-close close_process_modal' data-behavior='cancel_edit_stage'>×</button>",
      closeOnBgClick: false,
      callbacks: {
        afterClose: function() {
          if (restoreModalContentFlag) {
            restoreModalContent();
          }
        },
        // Add custom behaviors to the upper right cancel edit question button (the X).
        // This button is added by Magnific Popup JS when the modal is opened, so
        // behaviors must be added in a callback.
        open: function() {
          _addCloseModalBehaviors();
        }
      }
    });
  };

  function restoreModalContent() {
    var $stageModalWrapper = $('#' + $stageModalBackup.attr('id'));

    $stageModalBackup.addClass('mfp-hide');
    $stageModalWrapper.replaceWith($stageModalBackup);

    // add handlers again
    _addMagnificPopupBehaviors();
    _addEditStageBehaviors();
    _addCloseModalBehaviors();
    _addGlobalizedFieldsBehaviors();
    addDatepickerBehaviors();

    restoreModalContentFlag = false;
  };

  function _addCloseModalBehaviors() {
    $('.close_process_modal').unbind('click', closeModal).click(closeModal);
  };

  function closeModal(e) {
    if ($(e.target).attr('data-behavior') === 'cancel_edit_stage') {
      restoreModalContentFlag = true;
    }
    $.magnificPopup.close();
  };

  function _addEditStageBehaviors() {
    var $links = $('[data-behavior=edit_stage]');

    $links.unbind('click', saveStageModalState).click(saveStageModalState);
  };

  function saveStageModalState(e) {
    $stageModalBackup = $($(this).attr('href')).clone();
  };

  function _addGlobalizedFieldsBehaviors() {
    window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
  };

  function _addSetProcessDurationBehavior() {
    var $durationCheckbox = $('#process_has_duration');
    $durationCheckbox.click(function(){
      var $datepickersWrapper = $("[data-behavior='process_datepickers']");
      $datepickersWrapper.toggle('slow');
    });
  };

  function _handleSortableList() {
    var wrapper = "ul[data-behavior=sortable]";
    var positions = [];

    $(wrapper).sortable({
      update: function(e, ui) {
        _refreshPositions(wrapper);
        _requestUpdate(wrapper, _buildPositions(wrapper));
      },
      helper: _fixWidthHelper
    });
  }

  function _fixWidthHelper(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  }

  function _refreshPositions(wrapper) {
    $(wrapper).find("div.list_item").each(function(index) {
      $(this).attr("data-pos", index + 1);
    });
  };

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find("div.list_item").each(function(index) {
      positions.push({
        id: $(this).data("id"),
        position: index + 1
      });
    });

    return positions;
  };

  function _requestUpdate(wrapper, positions) {
    $.ajax({
      url: $(wrapper).data("sortable-target"),
      method: "POST",
      data: { positions: positions }
    });
  };
  return ProcessesController;
})();

this.GobiertoAdmin.processes_controller = new GobiertoAdmin.ProcessesController;
