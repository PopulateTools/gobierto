import '../../../assets/stylesheets/modules/jquery-ui.css';
import '../../lib/commons/modules/jquery-ui';

window.GobiertoAdmin.SortableComponent = (function() {
  function SortableComponent() {}

  SortableComponent.prototype.list = function(options) {
    let positionOffset = options.hasOwnProperty("positionOffset") ? options.positionOffset : 0
    _handleSortableList(options.wrapper, options.placeholder, positionOffset);
  };

  function _handleSortableList(wrapper, placeholder, positionOffset) {
    $(wrapper).sortable({
      items: '.list_item',
      handle: '.custom_handle',
      forcePlaceholderSize: true,
      placeholder: placeholder,
      update: function() {
        _refreshPositions(wrapper, positionOffset);
        _requestUpdate(wrapper, _buildPositions(wrapper, positionOffset));
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

  function _refreshPositions(wrapper, positionOffset) {
    $(wrapper).find(".list_item").each(function(index) {
      $(this).attr("data-pos", positionOffset + index + 1);
    });
  }

  function _buildPositions(wrapper, positionOffset) {
    var positions = [];

    $(wrapper).find(".list_item").each(function(index) {
      positions.push({
        id: $(this).data("id"),
        position: positionOffset + index + 1
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
