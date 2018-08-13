window.GobiertoAdmin.GobiertoPlansPlanNodesController = (function() {
  function GobiertoPlansPlanNodesController() {}

  var CustomDateField = function(config) {
    jsGrid.Field.call(this, config);
  };

  var LocalizedField = function(config) {
    jsGrid.Field.call(this, config);
  };

  LocalizedField.prototype = new jsGrid.Field({
    itemTemplate: function(value) {
      return "Pending";
    }
  });

  CustomDateField.prototype = new jsGrid.Field({
    sorter: function(date1, date2) {
      return new Date(date1) - new Date(date2);
    },
    itemTemplate: function(value) {
      return value ? new Date(value).toLocaleDateString() : null;
    },
    insertTemplate: function(value) {
      return this._insertPicker = $('<input type="text">').datepicker().datepicker({ language: I18n.locale });
    },
    editTemplate: function(value) {
      var dateValue = value ? new Date(value) : new Date()
      var datepicker = $('<input type="text">').datepicker().datepicker({ startDate: dateValue, language: I18n.locale });
      if (value) datepicker.data('datepicker').selectDate(dateValue);
      return this._editPicker = datepicker;
    },
    insertValue: function() {
      var dateValue = this._insertPicker.data("datepicker").selectedDates[0]
      return dateValue ? dateValue.toISOString() : null;
    },
    editValue: function() {
      var dateValue = this._insertPicker.data("datepicker").selectedDates[0]
      return dateValue ? dateValue.toISOString() : null;
    }
  });

  jsGrid.fields.customDateField = CustomDateField;
  jsGrid.fields.localizedField = LocalizedField;

  GobiertoPlansPlanNodesController.prototype.index = function(options) {
    $("#jsGrid").jsGrid({
      height: "80%",
      width: "100%",
      filtering: true,
      inserting: true,
      editing: true,
      sorting: true,
      paging: false,
      autoload: true,
      pageSize: 10,
      pageButtonCount: 5,
      deleteConfirm: "Do you really want to delete node?",
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
            url: options.item_path + "/" + item.id,
            data: item
          });
        },
        deleteItem: function(item) {
          return $.ajax({
            type: "DELETE",
            url: options.item_path + "/" + item.id
          });
        }
      },
      fields: [
        { name: "name_translations", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.name"),  type: "localizedField", width: 20 },
        { name: "status_translations", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.status"), type: "localizedField", width: 20 },
        { name: "progress", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.progress"), type: "number", width: 2 },
        { name: "starts_at", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.starts_at"), type: "customDateField", width: 10 },
        { name: "ends_at", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.ends_at"), type: "customDateField", width: 10 },
        { name: "options", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.options"), type: "textarea", width: 20 },
        { type: "control" }
      ]
    });
  };


  return GobiertoPlansPlanNodesController;
})();

window.GobiertoAdmin.gobierto_plans_plan_nodes_controller = new GobiertoAdmin.GobiertoPlansPlanNodesController;
