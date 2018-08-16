window.GobiertoAdmin.GobiertoPlansPlanNodesController = (function() {
  function GobiertoPlansPlanNodesController() {}

  var CustomDateField = function(config) {
    jsGrid.Field.call(this, config);
  };

  var LocalizedField = function(config) {
    jsGrid.Field.call(this, config);
  };

  LocalizedField.prototype = new jsGrid.Field({

    locales: ["es"],

    itemTemplate: function(value) {
      var text = value[I18n.locale];
      if (!text) {
        return Object.values(value).find(translation => !!translation);
      } else {
        return value[I18n.locale];
      }
    },
    insertTemplate: function(value) {
      var element = '';
      for (var i in this.locales) {
        element += '<span class="indication">' + this.locales[i] + '</span> <input type="text" data-locale="' + this.locales[i] +'">';
      }
      return this._insertPicker = $(element);
    },
    editTemplate: function(value) {
      var element = '';
      for (var i in this.locales) {
        element += '<span class="indication">' + this.locales[i] + '</span> <input type="text" data-locale="' + this.locales[i] +'" value="' + (value[this.locales[i]] || '') + '">';
      }
      return this._editPicker = $(element);
    },
    insertValue: function() {
      return generateTranslations(this._insertPicker);
    },
    editValue: function() {
      return generateTranslations(this._editPicker);
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

  function generateTranslations(picker) {
      translations = {}
      picker.filter("input").each(function(e) {
        translations[this.dataset.locale] = this.value;
      });
      return translations;
  };

  function nameValidator(locales) {
    return {
      validator: function(value, item, param) {
        return !Object.values(value).every(x => (x === null || x === ''));
      },
      message: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.errors.missing_name"),
      param: locales
    };
  };

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
        { name: "name_translations", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.name"), type: "localizedField", locales: options.locales, validate: nameValidator(options.locales) },
        { name: "status_translations", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.status"), type: "localizedField", locales: options.locales },
        { name: "progress", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.progress"), type: "number" },
        { name: "starts_at", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.starts_at"), type: "customDateField" },
        { name: "ends_at", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.ends_at"), type: "customDateField" },
        { name: "options_json", title: I18n.t("gobierto_admin.gobierto_plans.plans.edit_nodes.options"), type: "textarea" },
        { type: "control" }
      ]
    });
  };

  return GobiertoPlansPlanNodesController;
})();

window.GobiertoAdmin.gobierto_plans_plan_nodes_controller = new GobiertoAdmin.GobiertoPlansPlanNodesController;
