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
        : "";
    }
  });

  jsGrid.fields.decimal = jsGrid.DecimalField = DecimalField;

  jsGrid.ControlField.prototype._createGridButton = function(cls, tooltip, clickHandler) {
    let grid = this._grid;

    // Correspondance FontAwesome icons by action
    let map = {
      'edit': 'edit',
      'delete': 'trash',
      'mode insert-mode': '',
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
    if ($("#jsGrid").jsGrid("fieldOption", "commitment_id", "hasData")) {
      $("#jsGrid").jsGrid("option", "inserting", true)
      $('.jsgrid-insert-row input').first().focus();
    } else {
      window.alert(I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.all_commitments_used"))
    }
  }

  function _populateCommitments(endpoint, sel, selection) {
    $.ajax({
      type: "GET",
      url: endpoint
    }).done( function(response) {
      let opts = $.grep(response, function(element) { return (!element.edition || element.id === selection) })
      if (opts.length > 0) {
        if (sel) {
          for(let i = 0; i < opts.length; i++) {
            sel.append($("<option>")
                       .attr('value', opts[i].id)
                       .attr('selected', opts[i].id === selection)
                       .text(opts[i].title))
          }
          if (!($("#jsGrid").jsGrid("fieldOption", "commitment_id", "hasData") || selection)) {
            $("#jsGrid").jsGrid("fieldOption", "commitment_id", "hasData", true)
          }
        }
      } else {
        if ($("#jsGrid").jsGrid("fieldOption", "commitment_id", "hasData")) {
          $("#jsGrid").jsGrid("fieldOption", "commitment_id", "hasData", false)
        }
        $("#jsGrid").jsGrid("option", "inserting", false)
      }
    })
  }

  function _commitmentSelect(value, item, el) {
    let select = $('<select>')
    select.attr('id', `commitments_select-${ item ? item.id : 'new' }`)
    _populateCommitments(el.commitments_path, select, value)

    return select
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

      onItemDeleted: function(args) {
        args.grid.clearInsert()
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
          editing: true,
          inserting: true,
          width: "10%",
          validate: "required",
          align: "left",
          commitments_path: options.commitments_path,
          insertTemplate: function(value, item) {
            return this._insertPicker = _commitmentSelect(value, item, this);
          },
          editTemplate: function(value, item) {
            return this._editPicker = _commitmentSelect(value, item, this);
          },
          insertValue: function() {
            return this._insertPicker.val();
          },
          editValue: function() {
            return this._editPicker.val();
          },
          hasData: true
        },
        {
          name: "percentage",
          title: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.header.percentage"),
          type: "decimal",
          width: "6%",
          validate: [{
            validator: function(value, item) {
              return (value !== "" || (item.value !== "" && item.max_value !== ""))
            },
            message: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.errors.missing_values")
          },
          {
            validator: function(value, item) {
              return (value !== "" || item.max_value !== 0)
            },
            message: I18n.t("gobierto_admin.gobierto_citizens_charters.editions.index.errors.max_value_null")
          }]
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
