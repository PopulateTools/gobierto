import { Grid, Plugins } from 'slickgrid-es6';
import { Select2Formatter, Select2Editor } from './data_grid_plugin_select2';

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsHumanResourcesPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsHumanResourcesPluginController() {}

  var grid;

  GobiertoCommonCustomFieldRecordsHumanResourcesPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _deserializeTableData(inputValue) {
    var inputDict = JSON.parse(inputValue);
    let deserializedData = []

    for (var termId in inputDict) {
      var newRow = inputDict[termId]
      newRow.human_resource = termId
      deserializedData.push(newRow)
    }

    return deserializedData;
  }

  function _serializeTableData(data) {
    var serializedData = {}

    for (let i = 0; i < data.length; i++) {
      var humanResourceId = data[i].human_resource
      var humanResourceValues = {}

      var validKeys = $.map(Object.keys(data[0]), function(key) {
        if (key !== "human_resource" && data[0][key] != "") { return key }
      })

      $.each(validKeys, function(idx) {
        let date_key = validKeys[idx]
        humanResourceValues[date_key] = data[i][date_key]
      })

      serializedData[humanResourceId] = humanResourceValues
    }

    return JSON.stringify(serializedData);
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

      _applyPluginStyles(element)
      _slickGrid(id, data, vocabularyTerms)

      $("form").submit(
        function() {
          $(".v_container .v_el .form_item.plugin_field.data_grid").each(function(i) {
            let uid = $(this).data("uid")
            $(`input[name$='[${uid}][value]']`).val(
              _serializeTableData($(this).data("slickGrid").getData())
            );
          });
        }
      );
    })
  }

  function _applyPluginStyles(element) {
    element.wrap("<div class='v_container'><div class='v_el v_el_level v_el_full_content'></div></div>");
    element.find("div.custom_field_value").addClass("human_resources_table")
    element.find("div.data-container").addClass("slickgrid-container").css({ width: "100%", height: "500px" });
  }

  function _slickGrid(id, data, vocabularyTerms) {
    function _initializeGrid(id, data, columns, options) {
      var checkboxSelector = new Plugins.CheckboxSelectColumn({
        cssClass: "slick-cell-checkboxsel",
        hideSelectAllCheckbox: true
      });

      columns.unshift(checkboxSelector.getColumnDefinition());

      grid = new Grid(`#${id} .data-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', grid);

      grid.setSelectionModel(new Plugins.CellSelectionModel());

      grid.onAddNewRow.subscribe(function (e, args) {
        let item = args.item;
        grid.invalidateRow(data.length);
        data.push(item);
        grid.updateRowCount();
        grid.invalidate();
        grid.render();
        $(`#${grid.getOptions().itemsCountId}`).html(data.length);
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
        cssClass: "cell-title"
      },
      {
        id: "start_date",
        name: "Inicio",
        field: "start_date",
        width: 120,
        cssClass: "cell-title"
      },
      {
        id: "end_date",
        name: "Fin",
        field: "end_date",
        width: 120,
        cssClass: "cell-title"
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
