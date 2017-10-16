this.GobiertoAdmin.ScopesController = (function() {
  function ScopesController() {}

  ScopesController.prototype.index = function() {
    _handleSortableList();
  };

  function _handleSortableList() {
    var wrapper = "tbody[data-behavior=sortable]";
    var positions = [];

    $(wrapper).sortable({
      items: 'tr',
      handle: '.custom_handle',
      forcePlaceholderSize: true,
      placeholder: '<tr><td colspan="8">&nbsp;&nbsp;</td></tr>',
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
    $(wrapper).find("tr").each(function(index) {
      $(this).attr("data-pos", index + 1);
    });
  };

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find("tr").each(function(index) {
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

  return ScopesController;
})();

this.GobiertoAdmin.scopes_controller = new GobiertoAdmin.ScopesController;
