this.GobiertoAdmin.PersonController = (function() {
  function PersonController() {}

  PersonController.prototype.form = function() {
    _selectByDefault();
    _handlePositionSelector();
  };

  function _handlePositionSelector() {
    $('#person_category_politician').on('change', function(){
      var $target = $('[data-target]');
      $target.show();
    });
    $('#person_category_executive').on('change', function(){
      var $target = $('[data-target]');
      $target.hide();
    });
  }

  function _selectByDefault(){
    if(!$('#person_party_government').is(':checked') && !$('#person_party_opposition').is(':checked'))
      $('#person_party_government').prop('checked', true);
  }

  return PersonController;
})();

this.GobiertoAdmin.person_controller = new GobiertoAdmin.PersonController;
