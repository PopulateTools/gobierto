window.GobiertoAdmin.GobiertoBudgetsController = (function() {
  function GobiertoBudgetsController() {}

  GobiertoBudgetsController.prototype.options = function(options) {
    _handleMunicipalitiesAutocomplete(options);
    _comparison_tool_checkboxes();
  };

  function _handleMunicipalitiesAutocomplete(options) {
    var $field = $("#gobierto_budgets_options_comparison_compare_municipalities");
    $field.select2({
      multiple: true,
      ajax: {
        url: options.municipalities_suggestion_url,
        crossDomain: true,
        dataType: "json",
        method: "GET",
        data: params => ({ query: params.term }),
        processResults: function(data) {
          if (data === undefined) return [];
          var results = $.map(data.suggestions, function (obj) {
            obj.text = obj.name;
            obj.id = obj.id;
            return obj;
          });
          return { results: results };
        },
      }
    });
  }

  function _comparison_tool_checkboxes() {
    $("input[name='gobierto_budgets_options[comparison_tool_enabled]']").change(function () {
      if (!($("input[name='gobierto_budgets_options[comparison_tool_enabled]']").is(':checked'))) {
        $("input[name='gobierto_budgets_options[comparison_context_table_enabled]']").prop('checked', false);
        $("input[name='gobierto_budgets_options[comparison_compare_municipalities_enabled]']").prop('checked', false);
        $("input[name='gobierto_budgets_options[comparison_show_widget]']").prop('checked', false);
      }
    });
  }

  return GobiertoBudgetsController;
})();

window.GobiertoAdmin.gobierto_budgets_controller = new GobiertoAdmin.GobiertoBudgetsController;
