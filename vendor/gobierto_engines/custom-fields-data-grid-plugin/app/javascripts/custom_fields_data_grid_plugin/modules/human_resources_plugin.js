import { Grid, Editors, Plugins } from 'slickgrid-es6';
import { Select2Formatter, Select2Editor } from './data_grid_plugin_select2';
import CheckboxDeleteRowPlugin from './checkbox_delete_row_plugin';
import { applyPluginStyles } from './common_slickgrid_behavior';

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsHumanResourcesPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsHumanResourcesPluginController() {}

  var grid;

  GobiertoCommonCustomFieldRecordsHumanResourcesPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _deserializeTableData(inputValue) {
    if (inputValue === "null") return [];

    var inputDict = JSON.parse(inputValue);

    if ('human_resources' in inputDict) {
      return inputDict.human_resources;
    } else {
      return [];
    }
  }

  function _serializeTableData(data) {
    return JSON.stringify({ human_resources: data });
  }

  function _handlePluginData(uid) {
    var humanResourcesVocabularyId = $(`[data-uid=${uid}]`).attr("data-vocabulary-id");
    var vocabularyInfoPromise = new Promise((resolve) => {
      $.getJSON('/admin/api/vocabularies/' + humanResourcesVocabularyId, function(jsonData) {
        resolve(jsonData);
      });
    })

    vocabularyInfoPromise.then(function(jsonData) {
      let vocabularyTerms = jsonData["terms"];
      let element = $(`[data-uid=${uid}]`)
      let id = element.attr('id')
      let data = _deserializeTableData($(`#${id}`).find("input[name$='[value]'").val());

      applyPluginStyles(element, "human_resources")
      _slickGrid(id, data, vocabularyTerms)

      $("form").submit(
        function() {
          $(".v_container .v_el .form_item.plugin_field.human_resources").each(function(i) {
            let uid = $(this).data("uid")
            $(`input[name$='[${uid}][value]']`).val(
              _serializeTableData($(this).data("slickGrid").getData())
            );
          });
        }
      );
    })
  }

  function _slickGrid(id, data, vocabularyTerms) {
    function _initializeGrid(id, data, columns, options) {
      var checkboxSelector = new CheckboxDeleteRowPlugin({
        cssClass: "slick-cell-checkboxsel",
        hideSelectAllCheckbox: true
      });

      columns.unshift(checkboxSelector.getColumnDefinition());

      grid = new Grid(`#${id} .data-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', grid);

      grid.setSelectionModel(new Plugins.CellSelectionModel({selectActiveCell: false}));

      grid.onAddNewRow.subscribe(function (_e, args) {
        grid.invalidateRow(data.length);
        data.push(args.item);
        grid.updateRowCount();
        grid.render();
      });

      grid.registerPlugin(checkboxSelector);

      var deleteRowsButton = $('<button class="small js-delete-rows">Delete selected rows</button>');
      $(`#${id}`).append(deleteRowsButton);

      $('.js-delete-rows').click(function (e) {
        e.preventDefault();
        var selectedRows = grid.getSelectedRows();

        $.each(selectedRows, function(idx) {
          grid.getData().splice(selectedRows[idx], 1);
        })
        grid.invalidate()
      })

    }

    let humanResourcesDictionary = {}
    $.each(vocabularyTerms, function(idx) {
      let term = vocabularyTerms[idx];
      humanResourcesDictionary[term.id] = term.name_translations[I18n.locale]
    });

    let columns = [
      {
        id: "human_resource",
        name: "Recurso Humano",
        field: "human_resource",
        width: 120,
        cssClass: "cell-title",
        formatter: Select2Formatter,
        editor: Select2Editor,
        dataSource: humanResourcesDictionary
      },
      {
        id: "cost",
        name: "Coste",
        field: "cost",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Text
      },
      {
        id: "start_date",
        name: "Inicio",
        field: "start_date",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Text
      },
      {
        id: "end_date",
        name: "Fin",
        field: "end_date",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Text
      }
    ];

    // generice grid options
    let options = {
      editable: true,
      enableAddRow: true,
      enableCellNavigation: true,
      asyncEditorLoading: false,
      enableColumnReorder: false,
      autoEdit: true,
      itemsCountId: `${id}_items`
    };

    _initializeGrid(id, data, columns, options);
  }
  return GobiertoCommonCustomFieldRecordsHumanResourcesPluginController;
})();

window.GobiertoAdmin.gobierto_common_custom_field_records_human_resources_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsHumanResourcesPluginController;
