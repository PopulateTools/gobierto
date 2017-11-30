this.GobiertoAdmin.GobiertoBudgetsController = (function() {
  function GobiertoBudgetsController() {}

  function _handleMunicipalitiesAutocomplete(options) {
    var $field = $("#gobierto_budgets_options_comparison_compare_municipalities");
    console.log(options);
    $field.select2({
      multiple: true,
      ajax: {
        url: options.municipalities_suggestion_url,
        crossDomain: true,
        dataType: "json",
        method: "GET",
        data: function(params) {
          return { query: params.term };
        },
        processResults: function(data) {
          if(data === undefined) return [];
          var results = $.map(data.suggestions, function (obj) {
            obj.text = obj.data.name;
            obj.id = obj.data.id;
            return obj;
          });
          return { results: results };
        },
      }
    });
  }

  GobiertoBudgetsController.prototype.options = function(options) {
    _handleMunicipalitiesAutocomplete(options);
  };

  return GobiertoBudgetsController;
})();

this.GobiertoAdmin.gobierto_budgets_controller = new GobiertoAdmin.GobiertoBudgetsController;
