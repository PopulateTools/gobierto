import 'webpack-jquery-ui/sortable'

window.GobiertoAdmin.SortableComponent = (function() {
  function SortableComponent() {}

  SortableComponent.prototype.list = function(options) {
    _handleSortableList(options.wrapper, options.placeholder);
  };

  function _handleSortableList(wrapper, placeholder) {
    $(wrapper).sortable({
      items: '.list_item',
      handle: '.custom_handle',
      forcePlaceholderSize: true,
      placeholder: placeholder,
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
    $(wrapper).find(".list_item").each(function(index) {
      $(this).attr("data-pos", index + 1);
    });
  }

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find(".list_item").each(function(index) {
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

  return SortableComponent;
})();

window.GobiertoAdmin.sortable_component = new GobiertoAdmin.SortableComponent;
