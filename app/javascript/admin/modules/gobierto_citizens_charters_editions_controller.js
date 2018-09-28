import 'jsgrid'

window.GobiertoAdmin.GobiertoCitizensChartersEditionsController = (function() {
  function GobiertoCitizensChartersEditionsController() {}

  function dateString(date) {
    return date ? new Date(date.getTime() - date.getTimezoneOffset()*60000).toISOString() : null;
  }

  function DecimalField(config) {
    jsGrid.fields.number.call(this, config);
  }

  DecimalField.prototype = new jsGrid.fields.number({

    filterValue: function() {
      return this.filterControl.val()
        ? parseFloat(this.filterControl.val() || 0, 10)
        : undefined;
    },

    insertValue: function() {
      return this.insertControl.val()
        ? parseFloat(this.insertControl.val() || 0, 10)
        : undefined;
    },

    editValue: function() {
      return this.editControl.val()
        ? parseFloat(this.editControl.val() || 0, 10)
        : undefined;
    }
  });

  jsGrid.fields.decimal = jsGrid.DecimalField = DecimalField;

  jsGrid.ControlField.prototype._createGridButton = function(cls, tooltip, clickHandler) {
    let grid = this._grid;

    // Correspondance FontAwesome icons by action
    let map = {
      'edit': 'edit',
      'delete': 'trash',
      'mode insert-mode': 'plus-circle',
      'insert': 'check',
      'update': 'check',
      'cancel-edit': 'times',
    }

    let fa = map[cls.replace(new RegExp('jsgrid-', 'g'), '').replace(new RegExp('-button', 'g'), '')]
    let classname = `fa fa-${fa}`

    return $("<i>")
      .removeClass()
      .addClass(classname)
      .on("click", function(e) {
        clickHandler(grid, e);
      });
  };

  function _focusInsertMode() {
    $("#jsGrid").find(".fa-plus-circle").click();
    $('.jsgrid-insert-row input').first().focus();
  }

  GobiertoCitizensChartersEditionsController.prototype.index = function(options) {

    $(document).on("click", "span[data-toggle]", function () {
      const lang = $(this).data("toggle")
      const parent = $(this).closest(".lang-tabs").attr("id")
      // hide others input fields
      $(`#${parent} input[data-locale=${lang}]`).addClass("selected")
      // display language selected
      $(`#${parent} input[data-locale!=${lang}]`).removeClass("selected")
      // mark/unmark language selected
      $(`#${parent} span[data-toggle=${lang}]`).addClass("selected")
      $(`#${parent} span[data-toggle!=${lang}]`).removeClass("selected")
    })

    $("#jsGrid").jsGrid({
      width: "100%",
      filtering: false,
      inserting: true,
      editing: true,
      sorting: true,
      paging: false,
      autoload: true,
      pageSize: 10,
      pageButtonCount: 5,
      noDataContent: I18n.t("shared.jsgrid.not_found"),
      confirmDeleting: true,
      deleteConfirm: I18n.t("shared.jsgrid.delete_confirm"),
      invalidMessage: I18n.t("shared.jsgrid.invalid_message"),
      loadMessage: I18n.t("shared.jsgrid.load_message"),
      controller: {
        loadData: function(filter) {
          return $.ajax({
            type: "GET",
            url: options.collection_path,
            data: filter
          });
        },
        insertItem: function(item) {
          return $.ajax({
            type: "POST",
            url: options.collection_path,
            data: item
          });
        },
        updateItem: function(item) {
          return $.ajax({
            type: "PUT",
            url: options.item_path + item.id,
            data: item
          });
        },
        deleteItem: function(item) {
          return $.ajax({
            type: "DELETE",
            url: options.item_path + item.id
          });
        }
      },

      fields: [
        {
          name: "commitment_id",
          title: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.header.title"),
          type: "select",
          autosearch: true,
          items: options.commitments_list,
          valueField: "id",
          textField: "title",
          editing: false,
          inserting: true,
          width: "10%"
        },
        {
          name: "percentage",
          title: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.header.percentage"),
          type: "decimal",
          width: "6%"
        },
        {
          name: "value",
          title: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.header.value"),
          type: "decimal",
          width: "6%"
        },
        {
          name: "max_value",
          title: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.header.max_value"),
          type: "decimal",
          width: "6%"
        },
        {
          type: "control",
          editButton: true,
          deleteButton: true,
          modeSwitchButton: true,
          align: "center",
          width: "5%",
          filtering: false,
          inserting: true,
          editing: true,
          sorting: false,
          insertModeButtonTooltip: I18n.t("shared.jsgrid.insert_switch"),
          editButtonTooltip: I18n.t("shared.jsgrid.edit"),
          deleteButtonTooltip: I18n.t("shared.jsgrid.delete"),
          insertButtonTooltip: I18n.t("shared.jsgrid.insert"),
          updateButtonTooltip: I18n.t("shared.jsgrid.update"),
          cancelEditButtonTooltip: I18n.t("shared.jsgrid.cancel_edit")
        }
      ]
    });

    if (options.insert) {
      _focusInsertMode()
    }

    $(document).on("click", "a[data-insert]", function(e) {
      e.preventDefault()
      _focusInsertMode()
    })
  };

  return GobiertoCitizensChartersEditionsController;
})();

window.GobiertoAdmin.gobierto_citizens_charters_editions_controller = new GobiertoAdmin.GobiertoCitizensChartersEditionsController;
