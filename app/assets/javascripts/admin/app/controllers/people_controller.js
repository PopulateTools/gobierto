this.GobiertoAdmin.PeopleController = (function() {
  function PeopleController() {}

  PeopleController.prototype.index = function() {
    _handleSortableList();
  };

  function _handleSortableList() {
    var wrapper = "tbody[data-behavior=sortable]";
    var positions = [];

    sortable(wrapper, {
      items: 'tr',
      forcePlaceholderSize: true
    });

    $(wrapper).on("sortupdate", function(e) {
      _refreshPositions(wrapper);
      _requestUpdate(wrapper, _buildPositions(wrapper));
    });
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

  return PeopleController;
})();

this.GobiertoAdmin.people_controller = new GobiertoAdmin.PeopleController;
