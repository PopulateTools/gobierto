import { addDatepickerBehaviors } from './application'
import 'webpack-jquery-ui/sortable'

window.GobiertoAdmin.ProcessStagesController = (function() {

  function ProcessStagesController() {}

  ProcessStagesController.prototype.form = function() {
    _restoreModalContent();
  };

  ProcessStagesController.prototype.index = function() {
    _modifyActiveStage();
    _handleSortableList();
  };

  function _restoreModalContent() {
    addDatepickerBehaviors();
  }

  function _modifyActiveStage() {
    var str = window.location.href;
    var subStr= str.match("(.*)/processes/(.*)/process_stages");
    $("input[name='process[stages_attributes][active]']").click(function(){
        $.ajax({
            type: "POST",
            url: '/admin/participation/processes/' + subStr[2] + '/update_current_stage',
            dataType: 'json',
            data: { active_stage_id: $("input[name='process[stages_attributes][active]']:checked").val() }
        });
    });
  }

  function _handleSortableList() {
    var wrapper = "ul[data-behavior=sortable]";

    $(wrapper).sortable({
      update: function() {
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
  }

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find("div.list_item").each(function(index) {
      positions.push({
        id: $(this).data("id"),
        position: index + 1
      });
    });

    return positions;
  }

  function _requestUpdate(wrapper, positions) {
    $.ajax({
      url: $(wrapper).data("sortable-target"),
      method: "POST",
      data: { positions: positions }
    });
  }

  return ProcessStagesController;
})();

window.GobiertoAdmin.process_stages_controller = new GobiertoAdmin.ProcessStagesController;
